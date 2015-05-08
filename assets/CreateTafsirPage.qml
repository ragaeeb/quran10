import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: createPage
    property variant suiteId
    signal createTafsir(variant id, string author, string translator, string explainer, string title, string description, string reference)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onSuiteIdChanged: {
        if (suiteId) {
            tafsirHelper.fetchTafsirMetadata(createPage, suiteId);
        }
    }
    
    function onDataLoaded(id, results)
    {
        if (id == QueryId.FetchTafsirHeader && results.length > 0)
        {
            var data = results[0];
            
            authorField.text = data.author.toString();
            
            if (data.translator) {
                translatorField.text = data.translator.toString();
            }
            
            if (data.explainer) {
                explainerField.text = data.explainer.toString();
            }

            titleField.text = data.title;
            descriptionField.text = data.description;
            referenceField.text = data.reference;
        }
    }
    
    titleBar: TitleBar
    {
        title: suiteId > 0 ? qsTr("Edit Tafsir") + Retranslate.onLanguageChanged : qsTr("New Tafsir") + Retranslate.onLanguageChanged
        
        acceptAction: ActionItem
        {
            title: qsTr("Save") + Retranslate.onLanguageChanged
            imageSource: "images/dropdown/ic_accept_new_suite.png"
            enabled: true
            
            onTriggered: {
                console.log("UserEvent: CreateTafsirSaveTriggered");
                authorField.validator.validate();
                titleField.validator.validate();
                
                if (authorField.validator.valid && titleField.validator.valid) {
                    createTafsir( suiteId, authorField.text.trim(), translatorField.text.trim(), explainerField.text.trim(), titleField.text.trim(), descriptionField.text.trim(), referenceField.text.trim() );
                }
            }
        }
    }
    
    ScrollView
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            topPadding: 10
            
            IndividualTextField
            {
                id: authorField
                hintText: qsTr("Author name") + Retranslate.onLanguageChanged
                
                validator: Validator
                {
                    errorMessage: qsTr("Author name cannot be empty...") + Retranslate.onLanguageChanged
                    mode: ValidationMode.FocusLost
                    
                    onValidate: {
                        valid = authorField.text.trim().length > 0;
                    }
                }
            }
            
            IndividualTextField
            {
                id: translatorField
                field: "translator"
                hintText: qsTr("Translator") + Retranslate.onLanguageChanged
            }
            
            IndividualTextField
            {
                id: explainerField
                field: "explainer"
                hintText: qsTr("Explainer") + Retranslate.onLanguageChanged
            }
            
            TextField
            {
                id: titleField
                hintText: qsTr("Title") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                
                validator: Validator
                {
                    errorMessage: qsTr("Title cannot be empty...") + Retranslate.onLanguageChanged
                    mode: ValidationMode.FocusLost
                    
                    onValidate: {
                        valid = titleField.text.trim().length > 0;
                    }
                }
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: TafsirTitleDoubleTapped");
                            titleField.text = textUtils.toTitleCase( persist.getClipboardText() );
                        }
                    }
                ]
            }
            
            TextArea {
                id: descriptionField
                hintText: qsTr("Description...") + Retranslate.onLanguageChanged
                minHeight: ui.sdu(18.75)
                inputMode: TextAreaInputMode.Text
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: TafsirDescDoubleTapped");
                            descriptionField.text = persist.getClipboardText();
                        }
                    }
                ]
            }

            TextArea
            {
                id: referenceField
                hintText: qsTr("Reference...") + Retranslate.onLanguageChanged
                minHeight: ui.sdu(18.75)
                inputMode: TextAreaInputMode.Text
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveText
                input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                
                gestureHandlers: [
                    DoubleTapHandler
                    {
                        onDoubleTapped: {
                            console.log("UserEvent: TafsirRefDoubleTapped");
                            referenceField.text = persist.getClipboardText();
                        }
                    }
                ]
            }
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
            source: "IndividualPickerPage.qml"
        }
    ]
}