import bb.cascades 1.2

Delegate
{
    id: tutorialDelegate
    property string message
    property int horizontal: HorizontalAlignment.Left
    property int vertical: VerticalAlignment.Bottom
    property real lPadding: 0
    property real rPadding: 0
    property real tPadding: 0
    property real bPadding: 0
    property string asset: "images/progress/mushaf_circle.png"
    
    function show() {
        active = true;
    }
    
    sourceComponent: ComponentDefinition
    {
        Dialog
        {
            id: fsd
            
            onOpened: {
                dialogContainer.opacity = 1;
            }
            
            onCreationCompleted: {
                open();
            }
            
            Container
            {
                id: dialogContainer
                preferredWidth: Infinity
                preferredHeight: Infinity
                background: Color.create(0.0, 0.0, 0.0, 0.5)
                layout: DockLayout {}
                opacity: 0
                
                gestureHandlers: [
                    TapHandler {
                        onTapped: {
                            fsd.close();
                        }
                    }
                ]
                
                Container
                {
                    layout: DockLayout {}
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    Container
                    {
                        horizontalAlignment: horizontal
                        verticalAlignment: vertical
                        opacity: 0.8
                        leftPadding: lPadding
                        bottomPadding: bPadding
                        rightPadding: rPadding
                        topPadding: tPadding
                        
                        ImageView
                        {
                            imageSource: asset
                        }
                        
                        animations: [
                            ParallelAnimation {
                                id: tt
                                repeatCount: AnimationRepeatCount.Forever
                                
                                onCreationCompleted: {
                                    play();
                                }
                                
                                SequentialAnimation
                                {
                                    ScaleTransition {
                                        fromX: 1
                                        toX: 1.2
                                        fromY: 1
                                        toY: 1.2
                                        easingCurve: StockCurve.ExponentialOut
                                        duration: 750
                                    }
                                    
                                    ScaleTransition {
                                        fromX: 1.2
                                        toX: 1
                                        fromY: 1.2
                                        toY: 1
                                        easingCurve: StockCurve.ExponentialIn
                                        duration: 750
                                    }
                                }
                            }
                        ]
                    }
                    
                    Label {
                        text: message
                        textStyle.color: Color.White
                        textStyle.textAlign: TextAlign.Center
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Center
                        multiline: true
                    }
                }
            }
            
            onClosed: {
                active = false;
            }
        }
    }
}