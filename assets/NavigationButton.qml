import bb.cascades 1.3

ImageButton
{
    pressedImageSource: defaultImageSource
    property int multiplier: 1
    rotationZ: 180*multiplier
    signal animationFinished()
    
    animations: [
        SequentialAnimation
        {
            id: prevTransition
            delay: 1000
            
            TranslateTransition
            {
                toX: 0
                easingCurve: StockCurve.QuinticOut
                duration: 1500
                
                onCreationCompleted: {
                    fromX = (deviceUtils.pixelSize.width-ui.du(12))*multiplier;
                }
            }
            
            RotateTransition {
                fromAngleZ: 180*multiplier
                toAngleZ: 0
                duration: 1000
            }
            
            onEnded: {
                animationFinished();
            }
        }
    ]
    
    onCreationCompleted: {
        translationX = (deviceUtils.pixelSize.width-ui.du(12))*multiplier;
        prevTransition.play();
    }
}