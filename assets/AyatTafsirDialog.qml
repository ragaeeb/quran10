import bb.cascades 1.2
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
            
            if ( persist.tutorial( "tutorialTafsirExit", qsTr("To exit this dialog simply tap any area outside of the dialog!"), "asset:///images/menu/tafsir.png" ) ) {}
            else if ( persist.tutorial( "tutorialTafsirPinch", qsTr("If the font size is too small, you can simply pinch in to increase the font size!"), "asset:///images/dropdown/ic_info.png" ) ) {}
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
    
    function finish()
    {
        if ( !fader.isPlaying() )
        {
            fader.fromOpacity = 1;
            fader.toOpacity = 0;
            fader.play();
            scaleExit.play();
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
                    console.log("UserEvent: AyatTafsirDialogTapped");
                    
                    if (event.propagationPhase == PropagationPhase.AtTarget) {
                        finish();
                    }
                }
            }
        ]
        
        Container
        {
            id: contentContainer
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
                    
                    onEnded: {
                        if (tafsir) {
                            process();
                            footer.visible = true;
                        }
                    }
                },
                
                ScaleTransition
                {
                    id: scaleExit
                    fromY: 1
                    toY: 0
                    duration: 750
                    easingCurve: StockCurve.ExponentialIn
                    
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
    
    attachedObjects: [
        OrientationHandler {
            id: rotationHandler
            
            onOrientationChanged: {
                contentContainer.maxHeight = orientation == UIOrientation.Portrait ? deviceUtils.pixelSize.height-150 : deviceUtils.pixelSize.width;
            }
            
            onCreationCompleted: {
                orientationChanged(orientation);
            }
        },
        
        Delegate {
            source: "ClassicBackDelegate.qml"
            
            onCreationCompleted: {
                active = 'locallyFocused' in contentContainer;
            }
            
            onObjectChanged: {
                if (object) {
                    object.parentControl = mainContainer;
                    object.triggered.connect(finish);
                }
            }
        }
    ]
}