import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: createBioPage
    property variant bioId
    signal createBio(variant bioId, string authorField, string heading, string body, string reference)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onBioIdChanged: {
        if (bioId) {
            tafsirHelper.fetchBioMetadata(createBioPage, bioId);
        }
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchBioMetadata && data.length > 0)
        {
            var e = data[0];
            
            if (e.author) {
                authorField.text = e.author.toString();
            }
            
            if (e.heading) {
                heading.text = e.heading;
            }
            
            if (e.reference) {
                reference.text = e.reference;
            }
            
            if (e.body) {
                body.text = e.body;
            }
        }
    }
    
    titleBar: TitleBar
    {
        title: bioId > 0 ? qsTr("Edit Biography") + Retranslate.onLanguageChanged : qsTr("Create Biography") + Retranslate.onLanguageChanged
        
        acceptAction: ActionItem
        {
            id: saveAction
            title: qsTr("Save") + Retranslate.onLanguageChanged
            imageSource: "images/dropdown/save_bio.png"
            enabled: false
            
            onTriggered: {
                console.log("UserEvent: SaveBio");
                createBio( bioId, authorField.text.trim(), heading.text.trim(), body.text.trim(), reference.text.trim() );
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
            
            IndividualTextField
            {
                id: authorField
                table: "biographies"
                hintText: qsTr("Author name") + Retranslate.onLanguageChanged
            }
            
            TextField
            {
                id: heading
                horizontalAlignment: HorizontalAlignment.Fill
                hintText: qsTr("Heading...") + Retranslate.onLanguageChanged
                input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: BioHeadingDoubleTapped");
                            heading.text = textUtils.toTitleCase( persist.getClipboardText() );
                        }
                    }
                ]
            }
            
            TextArea
            {
                id: body
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheck | TextInputFlag.AutoCapitalization | TextInputFlag.Prediction
                horizontalAlignment: HorizontalAlignment.Fill
                hintText: qsTr("Enter body here...") + Retranslate.onLanguageChanged
                minHeight: ui.sdu(25)
                
                onTextChanging: {
                    saveAction.enabled = text.trim().length > 5;
                }
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: BioBodyTapped");
                            body.text = textUtils.optimize( global.getCapitalizedClipboard() );
                        }
                    }
                ]
            }
            
            TextArea
            {
                id: reference
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoCapitalization | TextInputFlag.PredictionOff
                horizontalAlignment: HorizontalAlignment.Fill
                hintText: qsTr("Enter reference here...") + Retranslate.onLanguageChanged
                minHeight: ui.sdu(18.75)
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: BioRefDoubleTapped");
                            reference.text = persist.getClipboardText();
                        }
                    }
                ]
            }
        }
    }
}