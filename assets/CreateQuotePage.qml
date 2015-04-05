import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: createPage
    property variant quoteId
    signal createQuote(variant id, string author, string body, string reference)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onQuoteIdChanged: {
        helper.fetchQuote(createPage, quoteId);
    }
    
    function onDataLoaded(id, results)
    {
        if (id == QueryId.FetchQuote && results.length > 0)
        {
            var data = results[0];
            
            authorField.text = data.author_id.toString();
            bodyField.text = data.body;
            referenceField.text = data.reference;
        }
    }
    
    titleBar: TitleBar
    {
        title: quoteId > 0 ? qsTr("Edit Quote") + Retranslate.onLanguageChanged : qsTr("New Quote") + Retranslate.onLanguageChanged
        
        acceptAction: ActionItem
        {
            title: qsTr("Save") + Retranslate.onLanguageChanged
            imageSource: "images/dropdown/save_quote.png"
            enabled: true
            
            onTriggered: {
                console.log("UserEvent: CreateQuoteSaveTriggered");
                authorField.validator.validate();
                
                if (authorField.validator.valid && bodyField.text.trim().length > 3 && referenceField.text.trim().length > 3) {
                    createQuote( quoteId, authorField.text.trim(), bodyField.text.trim(), referenceField.text.trim() );
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
            
            TextArea {
                id: bodyField
                hintText: qsTr("Body...") + Retranslate.onLanguageChanged
                minHeight: 150
                inputMode: TextAreaInputMode.Text
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: QuoteBodyDoubleTapped");
                            var x = persist.getClipboardText();
                            x = x.charAt(0).toUpperCase() + x.slice(1); 
                            bodyField.text = x;
                        }
                    }
                ]
            }

            TextArea {
                id: referenceField
                hintText: qsTr("Reference...") + Retranslate.onLanguageChanged
                minHeight: 150
                inputMode: TextAreaInputMode.Text
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveText
                input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: QuoteRefDoubleTapped");
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
        }
    ]
}