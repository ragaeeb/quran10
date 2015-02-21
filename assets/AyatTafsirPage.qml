import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: root
    property variant suitePageId
    property variant tafsir
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onSuitePageIdChanged: {
        helper.fetchTafsirContent(root, suitePageId);
    }
    
    function process()
    {
        titleLabel.text = tafsir.title;
        var bodyText = "";
        
        if ( (tafsir.author_hidden == 1 || tafsir.translator_hidden == 1 || tafsir.explainer_hidden == 1) && !reporter.isAdmin ) {
            bodyText = qsTr("[This tafsir is being intentionally suppressed. It may be released in a future update.]");
        } else {
            bodyText = qsTr("Author: %1").arg(tafsir.author);
            
            if (tafsir.translator.length > 0) {
                bodyText += "\nTranslator: %1".arg(tafsir.translator);
            }
            
            if (tafsir.explainer.length > 0) {
                bodyText += "\nExplained by: %1".arg(tafsir.explainer);
            }
            
            if (tafsir.description.length > 0) {
                bodyText += "\n\n%1".arg(tafsir.description);
            }
            
            bodyText += "\n\n%1".arg(tafsir.body);
            
            if (tafsir.reference.length > 0) {
                bodyText += "\n\n(%1)".arg(tafsir.reference);
            }
        }
        
        body.text = "\n"+bodyText+"\n";
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchTafsirContent && data.length > 0)
        {
            tafsir = data[0];
            
            if (scaler.state == AnimationState.Ended) {
                process();
            }
        }
    }
    
    Container
    {
        id: contentContainer
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        background: bg.imagePaint
        scaleY: 0
        
        Container
        {
            background: strip.imagePaint
            horizontalAlignment: HorizontalAlignment.Fill
            leftPadding: 50; rightPadding: 10; bottomPadding: 10; topPadding: 10
            
            Label {
                id: titleLabel
                horizontalAlignment: HorizontalAlignment.Fill
            }
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: strip
                    imageSource: "images/title/tafsir_title.amd"
                }
            ]
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            leftPadding: 10; rightPadding: 10
            
            gestureHandlers: [
                PinchHandler
                {
                    onPinchEnded: {
                        console.log("UserEvent: HadithTafsirDialogPinched");
                        var newValue = Math.floor(event.pinchRatio*body.textStyle.fontSizeValue);
                        newValue = Math.max(6,newValue);
                        newValue = Math.min(newValue, 18);
                        
                        persist.saveValueFor("tafsirSize", newValue);
                        body.textStyle.fontSizeValue = newValue;
                    }
                }
            ]
            
            TextArea
            {
                id: body
                editable: false
                backgroundVisible: false
                content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                opacity: 0
                textStyle.color: Color.White
                topPadding: 0;
                textStyle.fontSize: FontSize.PointValue
                textStyle.fontSizeValue: persist.getValueFor("tafsirSize")
                bottomPadding: 0; bottomMargin: 0
                verticalAlignment: VerticalAlignment.Fill
                
                onTextChanged: {
                    fader.play();
                }
                
                animations: [
                    FadeTransition {
                        id: fader
                        delay: 500
                        fromOpacity: 0
                        toOpacity: 1
                        duration: 750
                        easingCurve: StockCurve.QuinticOut
                    }
                ]
            }
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
        }
        
        Container
        {
            id: footer
            background: strip.imagePaint
            horizontalAlignment: HorizontalAlignment.Fill
            bottomPadding: 10; topPadding: 10
            visible: false
        }
        
        attachedObjects: [
            ImagePaintDefinition {
                id: bg
                imageSource: "images/backgrounds/downloads_bg.amd"
            }
        ]
        
        animations: [
            ScaleTransition
            {
                id: scaler
                fromY: 0
                toY: 1
                duration: 1000
                easingCurve: StockCurve.ExponentialOut
                delay: 250
                
                onEnded: {
                    if (tafsir) {
                        process();
                        footer.visible = true;
                    }
                }
                
                onCreationCompleted: {
                    play();
                }
            }
        ]
    }
}