import bb.cascades 1.3

ImageButton
{
    pressedImageSource: defaultImageSource
    property int multiplier: 1
    rotationZ: 180*multiplier
    signal animationFinished()
    
    animations: [
        RotateTransition
        {
            id: prevTransition
            fromAngleZ: 180*multiplier
            toAngleZ: 0
            duration: 1000
            delay: 1000
            
            onEnded: {
                animationFinished();
            }
        }
    ]
    
    onClicked: {
        reporter.record("NavButtonClicked", multiplier.toString());
    }
    
    onCreationCompleted: {
        prevTransition.play();
    }
}