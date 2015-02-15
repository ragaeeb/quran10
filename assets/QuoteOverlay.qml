import bb.cascades 1.0
import com.canadainc.data 1.0

ControlDelegate
{
    id: quoteControl
    property string benefitText
    horizontalAlignment: HorizontalAlignment.Right
    verticalAlignment: VerticalAlignment.Bottom
    delegateActive: false
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchRandomQuote && data.length > 0)
        {
            var quote = data[0];
            benefitText = qsTr("<html><i>\"%1\"</i>\n\n- <b>%2</b>\n\n[%3]\n\n\n</html>").arg(quote.body).arg(quote.author).arg(quote.reference);
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
            leftPadding: 10; rightPadding: 10; topPadding: 5; bottomPadding: 5
            background: bg.imagePaint
            maxWidth: 400
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
        }
    }
}