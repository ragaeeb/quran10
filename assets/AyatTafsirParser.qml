import bb.cascades 1.0
import com.canadainc.data 1.0

QtObject
{
    id: parser
    property variant suitePageId
    property variant tafsir
    property alias minHeightValue: contentContainer.minHeight
    property alias maxHeightValue: contentContainer.maxHeight
    property alias scalerAnim: scaler
    property alias faderAnim: fader
    property alias scaleExitAnim: scaleExit
    
    onSuitePageIdChanged: {
        helper.fetchTafsirContent(parser, suitePageId);
    }
    
    function process()
    {
        var title = tafsir.title;
        
        if (tafsir.heading && tafsir.heading.length > 0) {
            title += ": "+tafsir.heading;
        }
        
        titleLabel.text = title;
        
        var bodyText = "";
        
        if ( (tafsir.author_hidden == 1 || tafsir.translator_hidden == 1 || tafsir.explainer_hidden == 1) && !reporter.isAdmin ) {
            bodyText = qsTr("[This tafsir is being intentionally suppressed. It may be released in a future update.]");
        } else {
            var authorText = qsTr("Author: <a href=\"%2\">%1</a>%3").arg(tafsir.author).arg( tafsir.author_id.toString() ).arg( global.getSuffix(tafsir.author_birth, tafsir.author_death) );
            
            if (tafsir.translator.length > 0) {
                authorText += qsTr("\nTranslator: <a href=\"%2\">%1</a>%3").arg(tafsir.translator).arg( tafsir.translator_id.toString() ).arg( global.getSuffix(tafsir.translator_birth, tafsir.translator_death) );
            }
            
            if (tafsir.explainer.length > 0) {
                authorText += qsTr("\nExplained by: <a href=\"%2\">%1</a>%3").arg(tafsir.explainer).arg( tafsir.explainer_id.toString() ).arg( global.getSuffix(tafsir.explainer_birth, tafsir.explainer_death) );
            }
            
            if (tafsir.description.length > 0) {
                bodyText = tafsir.description+"\n\n";
            }
            
            bodyText += tafsir.body;
            
            if (tafsir.reference.length > 0) {
                bodyText += "\n\n(%1)".arg(tafsir.reference);
            }
            
            authors.text = "<html>"+authorText+"</html>";
            
            if ( persist.tutorial( "tutorialTafsirExit", qsTr("To exit this dialog simply tap any area outside of the dialog!"), "asset:///images/menu/tafsir.png" ) ) {}
            else if ( persist.tutorial( "tutorialTafsirPinch", qsTr("If the font size is too small, you can simply pinch in to increase the font size!"), "asset:///images/dropdown/ic_info.png" ) ) {}
        }
        
        body.text = bodyText+"\n";
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
    
    property variant mainContent: Container
    {
        id: contentContainer
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
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
                multiline: true
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
                FontSizePincher
                {
                    key: "tafsirSize"
                    minValue: 6
                    maxValue: 18
                    userEventId: "AyatTafsirDialogPinched"
                    
                    onPinchUpdated: {
                        body.textStyle.fontSizeValue = body.textStyle.fontSizeValue*event.pinchRatio;
                    }
                }
            ]
            
            TextArea
            {
                id: authors
                editable: false
                backgroundVisible: false
                content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                textStyle.color: Color.White
                textStyle.fontSize: FontSize.PointValue
                textStyle.fontSizeValue: body.textStyle.fontSizeValue
                bottomPadding: 0; bottomMargin: 0
                verticalAlignment: VerticalAlignment.Fill
                
                activeTextHandler: ActiveTextHandler
                {
                    onTriggered: {
                        var link = event.href.toString();
                        
                        if ( link.match("\\d+") ) {
                            persist.invoke("com.canadainc.Quran10.bio.previewer", "", "", "", link);
                        }
                        
                        event.abort();
                    }
                }
            }
            
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
                
                function onSettingChanged(key)
                {
                    if (key == "tafsirSize") {
                        textStyle.fontSizeValue = persist.getValueFor("tafsirSize");
                    }
                }
                
                onCreationCompleted: {
                    persist.settingChanged.connect(onSettingChanged);
                }
                
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
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
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
                
                onEnded: {
                    if (tafsir) {
                        parser.process();
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