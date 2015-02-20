import bb.cascades 1.2

Delegate
{
    function onQueueChanged() {
        active = true;
    }
    
    onCreationCompleted: {
        queue.queueChanged.connect(onQueueChanged);
    }
    
    sourceComponent: ComponentDefinition
    {
        FullScreenDialog
        {
            id: root
            
            onCreationCompleted: {
                open();
                queue.queueCompleted.connect(out.play);
            }
            
            function finish() {
                out.play();
            }
            
            onOpened: {
                tt.play();
                listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.None);
            }
            
            onClosed: {
                active = false;
            }
            
            dialogContent: Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                layout: DockLayout {}
                
                gestureHandlers: [
                    TapHandler {
                        onTapped: {
                            console.log("UserEvent: TransfersDialogTapped");
                            
                            if (event.propagationPhase == PropagationPhase.AtTarget) {
                                root.finish();
                            }
                        }
                    }
                ]
                
                Container
                {
                    id: contentContainer
                    background: bg.imagePaint
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Center
                    minHeight: 100
                    minWidth: 200
                    maxHeight: 400
                    maxWidth: 400
                    rightPadding: 30
                    translationX: 400
                    bottomPadding: 20
                    
                    animations: [
                        TranslateTransition {
                            id: tt
                            fromX: 400
                            toX: 0
                            easingCurve: StockCurve.ExponentialOut
                            delay: 250
                            duration: 750
                        },
                        
                        TranslateTransition
                        {
                            id: out
                            fromX: 0
                            toX: 400
                            easingCurve: StockCurve.CircularIn
                            delay: 250
                            duration: 750
                            
                            onEnded: {
                                root.close();
                            }
                        }
                    ]
                    
                    attachedObjects: [
                        ImagePaintDefinition {
                            id: bg
                            imageSource: "images/backgrounds/transfers_bg.amd"
                        }
                    ]
                    
                    Header {
                        subtitle: queue.queued
                        title: qsTr("Download Queue") + Retranslate.onLanguageChanged
                    }
                    
                    ListView
                    {
                        id: listView
                        dataModel: queue.model
                        maxWidth: 400
                        maxHeight: 400
                        
                        function itemType(data, indexPath)
                        {
                            if (data.tafsirPath) {
                                return "tafsir";
                            } else if (data.mushaf) {
                                return "mushaf";
                            } else if (data.recitation) {
                                return "recitation";
                            } else {
                                return "transfer";
                            }
                        }
                        
                        listItemComponents: [
                            ListItemComponent
                            {
                                type: "tafsir"
                                
                                TransferListItem {
                                    imageSource: "images/list/ic_tafsir.png"
                                }
                            },
                            
                            ListItemComponent
                            {
                                type: "mushaf"
                                
                                TransferListItem {
                                    imageSource: "images/list/ic_mushaf_page.png"
                                }
                            },
                            
                            ListItemComponent
                            {
                                type: "recitation"
                                
                                TransferListItem {
                                    imageSource: "images/list/mime_mp3.png"
                                }
                            },
                            
                            ListItemComponent
                            {
                                type: "transfer"
                                
                                TransferListItem {
                                    imageSource: "images/list/ic_tafsir.png"
                                }
                            }
                        ]
                    }
                }
            }
            
            attachedObjects: [
                OrientationHandler {
                    id: rotationHandler
                    
                    onOrientationChanged: {
                        contentContainer.maxHeight = orientation == UIOrientation.Portrait ? deviceUtils.pixelSize.height-150 : deviceUtils.pixelSize.width;
                    }
                    
                    onCreationCompleted: {
                        orientationChanged(orientation);
                    }
                },
                
                Delegate {
                    source: "ClassicBackDelegate.qml"
                    
                    onCreationCompleted: {
                        active = 'locallyFocused' in contentContainer;
                    }
                    
                    onObjectChanged: {
                        if (object) {
                            object.parentControl = mainContainer;
                            object.triggered.connect(root.finish);
                        }
                    }
                }
            ]
        }
    }
}