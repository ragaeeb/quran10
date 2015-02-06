import bb.cascades 1.0
import com.canadainc.data 1.0

FullScreenDialog
{
    id: root
    property variant suitePageId
    property variant tafsir
    
    onSuitePageIdChanged: {
        helper.fetchTafsirContent(root, suitePageId);
    }
    
    function process()
    {
        titleLabel.text = tafsir.title;
        var bodyText = qsTr("Author: %1").arg(tafsir.author);
        
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
        
        if (reporter.isAdmin) {
            bodyText = suitePageId+"\n\n"+bodyText;
        }

        body.text = "\n"+bodyText+"\n";
        
        if ( persist.tutorial( "tutorialTafsirExit", qsTr("To exit this dialog simply tap any area outside of the dialog!"), "asset:///images/menu/tafsir.png" ) ) {}
        else if ( persist.tutorial( "tutorialTafsirPinch", qsTr("If the font size is too small, you can simply pinch in to increase the font size!"), "asset:///images/dropdown/ic_info.png" ) ) {}
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
    
    dialogContent: Container
    {
        bottomPadding: 30
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        gestureHandlers: [
            TapHandler {
                onTapped: {
                    console.log("UserEvent: HadithTafsirDialogTapped");
                    
                    if (event.propagationPhase == PropagationPhase.AtTarget) {
                        fader.fromOpacity = 1;
                        fader.toOpacity = 0;
                        fader.play();
                        scaleExit.play();
                    }
                }
            }
        ]
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            background: bg.imagePaint
            minHeight: 200
            minWidth: 200
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
                    
                    onTextChanged: {
                        fader.play();
                    }
                    
                    animations: [
                        FadeTransition {
                            id: fader
                            fromOpacity: 0
                            toOpacity: 1
                            duration: 750
                            easingCurve: StockCurve.BackOut
                        }
                    ]
                }
            }
            
            Container
            {
                background: strip.imagePaint
                horizontalAlignment: HorizontalAlignment.Fill
                minWidth: 500
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
                    easingCurve: StockCurve.QuinticOut
                    
                    onEnded: {
                        if (tafsir) {
                            process();
                        }
                    }
                },
                
                ScaleTransition
                {
                    id: scaleExit
                    fromY: 1
                    toY: 0
                    duration: 750
                    easingCurve: StockCurve.QuinticIn
                    
                    onEnded: {
                        root.close();
                    }
                }
            ]
        }
    }
    
    onOpened: {
        scaler.play();
    }
}