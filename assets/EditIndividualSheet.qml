import bb.cascades 1.0

Sheet
{
    id: sheet
    property variant indexPath
    property variant data
    signal saveClicked(variant indexPath, variant id, string prefix, string name, string kunya, string uri, string bio, bool hidden)
    
    onCreationCompleted: {
        open();
    }
    
    onOpened: {
        hidden.checked = data.hidden == 1;
        
        if (data.prefix) {
            prefix.text = data.prefix;
        }
        
        if (data.name) {
            name.text = data.name;
        }
        
        if (data.kunya) {
            kunya.text = data.kunya;
        }
        
        if (data.uri) {
            uri.text = data.uri;
        }
        
        if (data.biography) {
            bio.text = data.biography;
        }
        
        name.requestFocus();
    }
    
    onClosed: {
        parent.active = false;
    }
    
    Page
    {
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: TitleBar
        {
            title: qsTr("Edit") + Retranslate.onLanguageChanged

            dismissAction: ActionItem
            {
                id: cancelAction
                imageSource: "images/dropdown/ic_cancel_individual.png"
                title: qsTr("Cancel") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: CancelEditIndividual");
                    sheet.close();
                }
            }

            acceptAction: ActionItem
            {
                id: saveAction
                imageSource: "images/dropdown/ic_save_individual.png"
                title: qsTr("Save") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: SaveEditIndividual");
                    
                    name.validator.validate();
                    uri.validator.validate();
                    
                    if (name.validator.valid && uri.validator.valid) {
                        saveClicked(indexPath, data.id, prefix.text.trim(), name.text.trim(), kunya.text.trim(), uri.text.trim(), bio.text.trim(), hidden.checked);
                    } else {
                        persist.showToast( qsTr("One of the fields is incomplete!"), "", "asset:///images/menu/ic_bookmark_delete.png" );
                    }
                }
            }
        }
        
        Container
        {
            topPadding: 10
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container
            {
                leftPadding: 10; rightPadding: 10
                
                CheckBox {
                    id: hidden
                    text: qsTr("Hidden") + Retranslate.onLanguageChanged
                }
            }
            
            TextField
            {
                id: prefix
                hintText: qsTr("Prefix (ie: al-Hafidh, Shaykh)") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
            }
            
            TextField
            {
                id: name
                hintText: qsTr("Name...") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                
                validator: Validator
                {
                    errorMessage: qsTr("Invalid name") + Retranslate.onLanguageChanged
                    mode: ValidationMode.FocusLost
                    
                    onValidate: { 
                        valid = name.text.trim().length > 3;
                    }
                }
            }
            
            TextField
            {
                id: kunya
                hintText: qsTr("Kunya...") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
            }
            
            TextField
            {
                id: uri
                hintText: qsTr("URL (ie: http://www.canadainc.org)") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                inputMode: TextFieldInputMode.Url
                
                validator: Validator
                {
                    errorMessage: qsTr("Invalid URL") + Retranslate.onLanguageChanged
                    mode: ValidationMode.FocusLost
                    
                    onValidate: { 
                        var regex=/^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/
                        valid = uri.text.trim().length == 0 || regex.test( uri.text.trim() );
                    }
                }
            }

            TextArea {
                id: bio
                hintText: qsTr("Biography...") + Retranslate.onLanguageChanged
                minHeight: 150
                inputMode: TextAreaInputMode.Text
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
            }
        }
    }
}