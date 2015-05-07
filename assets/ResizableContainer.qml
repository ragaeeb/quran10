import bb.cascades 1.0

Container
{
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    property real ratio: 0.4
    property real screenHeight: 1280
    property alias headerTitle: header.title
    property alias headerSubtitle: header.subtitle

    Header
    {
        id: header
        translationX: 1400
        
        gestureHandlers: [
            TapHandler
            {
                onTapped: {
                    ratio = 0.7;
                    reporter.record("ResizeContainerTapped");
                }
            }
        ]
        
        animations: [
            TranslateTransition {
                id: tt
                fromX: 1400
                toX: 0
                duration: 1000
                easingCurve: StockCurve.QuadraticOut
                delay: 250
                
                onCreationCompleted: {
                    tt.play();
                }
            }
        ]
    }
    
    attachedObjects: [
        OrientationHandler {
            id: rotationHandler
            
            onOrientationChanged: {
                screenHeight = orientation == UIOrientation.Portrait ? deviceUtils.pixelSize.height : deviceUtils.pixelSize.width;
            }
            
            onCreationCompleted: {
                orientationChanged(orientation);
            }
        }
    ]
}