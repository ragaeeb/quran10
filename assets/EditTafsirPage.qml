import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: editPage
    property variant suiteId
    signal editTafsir(variant id, string author, string translator, string explainer, string title, string description, string reference)
    
    onSuiteIdChanged: {
        helper.fetchTafsirMetadata(editPage, suiteId);
    }
    
    function onDataLoaded(id, results)
    {
        if (id == QueryId.FetchTafsirHeader && results.length > 0)
        {
            var data = results[0];
            
            authorField.text = data.author;
            translatorField.text = data.translator;
            explainerField.text = data.explainer;
            titleField.text = data.title;
            descriptionField.text = data.description;
            referenceField.text = data.reference;
            
            dropTop.play();
        }
    }
    
    titleBar: TitleBar
    {
        title: qsTr("Edit Tafsir") + Retranslate.onLanguageChanged
        
        acceptAction: ActionItem
        {
            title: qsTr("Save") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_select_more.png"
            enabled: true
            
            onTriggered: {
                console.log("UserEvent: EditTafsirSaveTriggered");
                authorField.validator.validate();
                titleField.validator.validate();
                
                if (authorField.validator.valid && titleField.validator.valid) {
                    editTafsir( suiteId, authorField.text.trim(), translatorField.text.trim(), explainerField.text.trim(), titleField.text.trim(), descriptionField.text.trim(), referenceField.text.trim() );
                }
            }
        }
    }
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    ScrollView
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        Container
        {
            id: fieldsContainer
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            TextField
            {
                id: authorField
                hintText: qsTr("Author name") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                translationY: -600
                
                validator: Validator
                {
                    errorMessage: qsTr("Author name must be at least 3 characters long...") + Retranslate.onLanguageChanged
                    mode: ValidationMode.FocusLost
                    
                    onValidate: {
                        valid = authorField.text.trim().length > 3;
                    }
                }
            }
            
            TextField
            {
                id: translatorField
                hintText: qsTr("Translator") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                translationY: -600
                
                animations: [
                    TranslateTransition
                    {
                        id: tt2
                        fromX: -100
                        toX: 0
                        easingCurve: StockCurve.QuadraticIn
                    }
                ]
            }
            
            TextField
            {
                id: explainerField
                hintText: qsTr("Explainer") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                translationY: -600
            }
            
            TextField
            {
                id: titleField
                hintText: qsTr("Title") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                translationY: 1440
                
                validator: Validator
                {
                    errorMessage: qsTr("Title cannot be empty...") + Retranslate.onLanguageChanged
                    mode: ValidationMode.FocusLost
                    
                    onValidate: {
                        valid = titleField.text.trim().length > 0;
                    }
                }
            }
            
            TextArea {
                id: descriptionField
                hintText: qsTr("Description...") + Retranslate.onLanguageChanged
                minHeight: 150
                inputMode: TextAreaInputMode.Text
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                translationY: 1440
            }

            TextArea {
                id: referenceField
                hintText: qsTr("Reference...") + Retranslate.onLanguageChanged
                minHeight: 150
                inputMode: TextAreaInputMode.Text
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveText
                input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                translationY: 1440
            }
        }
        
        animations: [
            ParallelAnimation
            {
                id: dropTop
                
                SequentialAnimation
                {
                    TranslateTransition
                    {
                        target: authorField
                        fromY: -600
                        toY: 0
                        easingCurve: StockCurve.QuinticOut
                        duration: 750
                    }
                    
                    TranslateTransition
                    {
                        target: translatorField
                        fromY: -600
                        toY: 0
                        easingCurve: StockCurve.BackOut
                        duration: 750
                    }
                    
                    TranslateTransition
                    {
                        target: explainerField
                        fromY: -600
                        toY: 0
                        easingCurve: StockCurve.CircularOut
                        duration: 750
                    }
                }
                
                SequentialAnimation
                {
                    TranslateTransition
                    {
                        target: titleField
                        fromY: 1440
                        toY: 0
                        easingCurve: StockCurve.QuarticInOut
                        duration: 750
                    }
                    
                    TranslateTransition
                    {
                        target: descriptionField
                        fromY: 1440
                        toY: 0
                        easingCurve: StockCurve.QuinticOut
                        duration: 750
                    }
                    
                    TranslateTransition
                    {
                        target: referenceField
                        fromY: 1440
                        toY: 0
                        easingCurve: StockCurve.BackOut
                        duration: 750
                    }
                }
            }
        ]
    }
}