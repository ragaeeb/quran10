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
        
        gestureHandlers: [
            TapHandler
            {
                onTapped: {
                    ratio = 0.7;
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