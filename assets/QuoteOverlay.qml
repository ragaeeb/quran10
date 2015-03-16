import bb.cascades 1.0
import com.canadainc.data 1.0

ControlDelegate
{
    id: quoteControl
    property string author
    property string body
    property string reference
    property string benefitText
    horizontalAlignment: HorizontalAlignment.Right
    verticalAlignment: VerticalAlignment.Bottom
    delegateActive: false
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchRandomQuote && data.length > 0)
        {
            var quote = data[0];
            author = quote.author;
            body = quote.body;
            reference = quote.reference;
            benefitText = qsTr("<html><i>“%1”</i>\n\n- <b>%2%4</b>\n\n[%3]\n\n\n</html>").arg(body).arg(author).arg(reference).arg( global.getSuffix(quote.birth, quote.death) );
            delegateActive = true;
        }
    }
    
    function process() {
        helper.fetchRandomQuote(quoteControl);
    }
    
    sourceComponent: ComponentDefinition
    {
        Container
        {
            id: quoteContainer
            leftPadding: 10; rightPadding: 10; topPadding: 5; bottomPadding: 13+benefitText.length*0.1
            background: bg.imagePaint
            maxWidth: 500
            minHeight: 275
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Bottom
            layout: DockLayout {}
            
            Label {
                text: benefitText
                multiline: true
                horizontalAlignment: HorizontalAlignment.Right
                textStyle.textAlign: TextAlign.Right
                textStyle.fontSize: FontSize.XXSmall
            }
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: bg
                    imageSource: "images/toast/quote_bg.png"
                }
            ]
            
            animations: [
                TranslateTransition
                {
                    id: out
                    toX: 500
                    toY: 500
                    easingCurve: StockCurve.ExponentialIn
                    duration: 1000
                    delay: 4000+benefitText.length*5
                    
                    onEnded: {
                        delegateActive = false;
                    }
                    
                    onCreationCompleted: {
                        play();
                    }
                }
            ]
            
            gestureHandlers: [
                TapHandler {
                    onTapped: {
                        console.log("UserEvent: QuoteTapped");
                        
                        if ( out.isPlaying() )
                        {
                            quoteContainer.translationX = out.toX;
                            quoteContainer.translationY = out.toY;
                            out.stop();
                            out.ended();
                        }
                    }
                }
            ]
            
            contextActions: [
                ActionSet
                {
                    id: actionSet
                    title: author
                    subtitle: reference
                    
                    ActionItem
                    {
                        id: copyAction
                        title: qsTr("Copy") + Retranslate.onLanguageChanged
                        imageSource: "images/menu/ic_copy.png"
                        
                        onTriggered: {
                            console.log("UserEvent: MultiCopy");
                            persist.copyToClipboard( qsTr("“%1” - %2 (%3)").arg(body).arg(author).arg(reference) );
                        }
                    }
                }
            ]
            
            onCreationCompleted: {
                if ( "navigation" in quoteContainer ) {
                    var nav = quoteContainer.navigation;
                    nav.focusPolicy = 0x2;
                }
            }
        }
    }
}