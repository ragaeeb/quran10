import bb.cascades 1.3

Page
{
    property variant data
    signal createBio(variant content)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onDataChanged: {
        for (var i = sc.count()-1; i >= 0; i--)
        {
            if ( sc.at(i).value == data.points ) {
                sc.selectedIndex = i;
                break;
            }
        }
        
        if (data.author_id) {
            from.text = data.author_id;
        }
        
        if (data.reference) {
            reference.text = data.reference;
        }
        
        if (data.body) {
            body.text = data.body;
        }
    }
    
    actions: [
        ActionItem
        {
            id: saveAction
            title: qsTr("Save") + Retranslate.onLanguageChanged
            imageSource: "images/dropdown/save_quote.png"
            enabled: false
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: SaveBio");
                
                var result = data;
                result.author_id = from.text.trim();
                result.points = sc.selectedValue;
                result.body = body.text.trim();
                result.reference = reference.text.trim();
                
                createBio(result);
            }
        }
    ]
    
    titleBar: TitleBar
    {
        title: data && data.target ? qsTr("Edit Biography") + Retranslate.onLanguageChanged : qsTr("Create Biography") + Retranslate.onLanguageChanged
    }
    
    ScrollView
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            SegmentedControl
            {
                id: sc
                horizontalAlignment: HorizontalAlignment.Fill
                bottomMargin: 0
                
                Option {
                    imageSource: "images/list/ic_dislike.png"
                    text: qsTr("Jarh") + Retranslate.onLanguageChanged
                    value: -1
                }
                
                Option {
                    imageSource: "images/list/mime_doc.png"
                    text: qsTr("Biography") + Retranslate.onLanguageChanged
                    value: undefined
                    selected: true
                }
                
                Option {
                    imageSource: "images/list/ic_like.png"
                    text: qsTr("Tahdeel") + Retranslate.onLanguageChanged
                    value: 1
                }
            }
            
            IndividualTextField
            {
                id: from
                hintText: qsTr("Author name") + Retranslate.onLanguageChanged
            }
            
            TextArea
            {
                id: body
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheck | TextInputFlag.AutoCapitalization | TextInputFlag.Prediction
                horizontalAlignment: HorizontalAlignment.Fill
                hintText: qsTr("Enter biography here...") + Retranslate.onLanguageChanged
                minHeight: ui.sdu(25)
                
                onTextChanging: {
                    saveAction.enabled = text.trim().length > 5;
                }
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: TafsirHeadingDoubleTapped");
                            body.text = textUtils.optimize( persist.getClipboardText() );
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
                            console.log("UserEvent: TafsirHeadingDoubleTapped");
                            reference.text = persist.getClipboardText();
                        }
                    }
                ]
            }
        }
    }
}