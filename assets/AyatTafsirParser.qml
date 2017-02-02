import bb.cascades 1.2
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
    signal notFound()
    
    onSuitePageIdChanged: {
        if (suitePageId) {
            helper.fetchTafsirContent(parser, suitePageId);
        }
    }
    
    function process()
    {
        var title = tafsir.title;
        
        if (tafsir.heading && tafsir.heading.length > 0) {
            title += ": "+tafsir.heading;
        }
        
        titleLabel.text = title;
        
        var bodyText = "";
        
        var authorText = "";
        
        if (tafsir.author.length > 0) {
            authorText = qsTr("Author: <a href=\"%2\">%1</a>%3").arg(tafsir.author).arg( tafsir.author_id.toString() ).arg( global.getSuffix(tafsir.author_birth, tafsir.author_death) );
        } else {
            authorText = qsTr("Author: Unknown");
        }
        
        if (tafsir.translator.length > 0) {
            authorText += qsTr("\nTranslator: <a href=\"%2\">%1</a>%3").arg(tafsir.translator).arg( tafsir.translator_id.toString() ).arg( global.getSuffix(tafsir.translator_birth, tafsir.translator_death) );
        }
        
        if (tafsir.explainer.length > 0) {
            authorText += qsTr("\nExplained by: <a href=\"%2\">%1</a>%3").arg(tafsir.explainer).arg( tafsir.explainer_id.toString() ).arg( global.getSuffix(tafsir.explainer_birth, tafsir.explainer_death) );
        }
        
        bodyText += tafsir.body;
        
        var reference = tafsir.reference;
        
        if (tafsir.suite_pages_reference) {
            reference = tafsir.suite_pages_reference;
        }
        
        if (reference.length > 0) {
            bodyText += "\n\n(%1)".arg(reference);
        }
        
        authors.text = "<html>"+authorText+"</html>";
        
        body.text = bodyText+"\n";
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchTafsirContent)
        {
            if (data.length > 0)
            {
                tafsir = data[0];
                
                if (scaler.state == AnimationState.Ended) {
                    process();
                }
            } else {
                body.text = qsTr("Article not found.");
                notFound();
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
            layout: DockLayout {}
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
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
                                reporter.record("OpenTafsirLink", link);
                            }
                            
                            event.abort();
                        }
                    }
                }
                
                ScrollView
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
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
                        bottomPadding: 0; bottomMargin: 0
                        verticalAlignment: VerticalAlignment.Fill
                        
                        function onSettingChanged(newValue, key) {
                            textStyle.fontSizeValue = newValue;
                        }
                        
                        onCreationCompleted: {
                            persist.registerForSetting(body, "tafsirSize");
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
                                
                                onEnded: {
                                    reporter.record("TafsirOpened", suitePageId.toString());
                                }
                            }
                        ]
                    }
                    
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
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
                        
                        tutorial.exec( "tapBio", qsTr("Tap on the author's name to see his/her profile, biography, quotes, and works."), HorizontalAlignment.Left, VerticalAlignment.Top, tutorial.du(14), 0, tutorial.du(14) );
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