import bb.cascades 1.0

ImageButton
{
    pressedImageSource: defaultImageSource
    property int multiplier: 1
    rotationZ: 180*multiplier
    translationX: 1000*multiplier
    signal animationFinished()
    
    animations: [
        SequentialAnimation
        {
            id: prevTransition
            delay: 1000
            
            TranslateTransition
            {
                fromX: 1000*multiplier
                toX: 0
                easingCurve: StockCurve.QuinticOut
                duration: 1500
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
        prevTransition.play();
    }
}