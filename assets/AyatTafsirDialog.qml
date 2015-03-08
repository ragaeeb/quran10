import bb.cascades 1.2

FullScreenDialog
{
    id: root
    property alias suitePageId: parser.suitePageId
    
    function finish()
    {
        if ( !parser.faderAnim.isPlaying() )
        {
            parser.faderAnim.fromOpacity = 1;
            parser.faderAnim.toOpacity = 0;
            parser.faderAnim.play();
            parser.scaleExitAnim.play();
        }
    }
    
    dialogContent: Container
    {
        bottomPadding: 30
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        gestureHandlers: [
            TapHandler {
                onTapped: {
                    console.log("UserEvent: AyatTafsirDialogTapped");
                    
                    if (event.propagationPhase == PropagationPhase.AtTarget) {
                        finish();
                    }
                }
            }
        ]
        
        onCreationCompleted: {
            add(parser.mainContent);
        }
    }
    
    onOpened: {
        parser.scalerAnim.play();
    }
    
    attachedObjects: [
        OrientationHandler {
            id: rotationHandler
            
            onOrientationChanged: {
                parser.maxHeightValue = orientation == UIOrientation.Portrait ? deviceUtils.pixelSize.height-150 : deviceUtils.pixelSize.width;
            }
            
            onCreationCompleted: {
                orientationChanged(orientation);
            }
        },
        
        Delegate {
            source: "ClassicBackDelegate.qml"
            
            onCreationCompleted: {
                active = 'locallyFocused' in parser.mainContent;
            }
            
            onObjectChanged: {
                if (object) {
                    object.parentControl = parser.mainContent;
                    object.triggered.connect(finish);
                }
            }
        },
        
        AyatTafsirParser {
            id: parser
            minHeightValue: 200
            maxHeightValue: 200
        }
    ]
}