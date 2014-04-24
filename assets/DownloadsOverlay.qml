import bb.cascades 1.0

ControlDelegate
{
    property string downloadText
    horizontalAlignment: HorizontalAlignment.Right
    verticalAlignment: VerticalAlignment.Center
    signal cancelClicked();
    
    sourceComponent: ComponentDefinition
    {
        Container
        {
            translationX: 225
            
            animations: [
                TranslateTransition {
                    id: animator
                    toX: 0
                    easingCurve: StockCurve.QuarticOut
                    duration: 1500
                    delay: 1000
                }
            ]
            
            onCreationCompleted: {
                animator.play();
            }
            
            leftPadding: 10; rightPadding: 10
            background: bg.imagePaint
            preferredHeight: 200
            preferredWidth: 200
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}
            
            Button
            {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                text: downloadText
                imageSource: "images/ic_cancel.png"
                preferredWidth: 125
                
                onClicked: {
                    animator.delay = 0;
                    animator.toX = 225;
                    animator.play();
                    animator.ended.connect(cancelClicked);
                }
            }
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: bg
                    imageSource: "images/backgrounds/downloads_bg.png"
                }
            ]
        }
    }
}