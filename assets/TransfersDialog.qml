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
        Dialog
        {
            id: root
            
            onCreationCompleted: {
                open();
                queue.queueCompleted.connect(root.finish);
            }
            
            function finish() {
                if ( !out.isPlaying() ) {
                    out.play();
                }
            }
            
            onOpened: {
                tt.play();
                listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.None);
                dialogContainer.opacity = 1;
            }
            
            onClosed: {
                active = false;
            }
            
            Container
            {
                id: dialogContainer
                preferredWidth: Infinity
                preferredHeight: Infinity
                background: Color.create(0.0, 0.0, 0.0, 0.5)
                layout: DockLayout {}
                opacity: 0
                
                Container
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
                        minHeight: 200
                        minWidth: 300
                        maxHeight: 400
                        maxWidth: 400
                        rightPadding: 30
                        translationX: 400
                        bottomPadding: 20
                        layout: DockLayout {}
                        
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
                        
                        Container
                        {
                            topPadding: 30
                            
                            EmptyDelegate
                            {
                                delegateActive: queue.queued == 0
                                graphic: "images/placeholders/empty_downloads.png"
                                labelText: qsTr("No downloads queued or active yet.") + Retranslate.onLanguageChanged
                            }
                        }
                        
                        Container
                        {
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            visible: queue.queued > 0
                            
                            Header {
                                subtitle: queue.queued
                                title: qsTr("Download Queue") + Retranslate.onLanguageChanged
                            }
                            
                            ListView
                            {
                                id: listView
                                maxWidth: 400
                                maxHeight: 400
                                
                                onCreationCompleted: {
                                    dataModel = queue.model;
                                }
                                
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
                                            successImageSource: "images/list/ic_tafsir.png"
                                        }
                                    },
                                    
                                    ListItemComponent
                                    {
                                        type: "mushaf"
                                        
                                        TransferListItem {
                                            successImageSource: "images/list/ic_mushaf_page.png"
                                        }
                                    },
                                    
                                    ListItemComponent
                                    {
                                        type: "recitation"
                                        
                                        TransferListItem {
                                            successImageSource: "images/list/mime_mp3.png"
                                        }
                                    },
                                    
                                    ListItemComponent
                                    {
                                        type: "transfer"
                                        
                                        TransferListItem {
                                            successImageSource: "images/list/ic_tafsir.png"
                                        }
                                    }
                                ]
                            }
                        }
                    }
                    
                    CircularProgressControl
                    {
                        id: cpc
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        visible: false
                        
                        function onDeflationProgressChanged(current, total)
                        {
                            visible = true;
                            labelText = qsTr("Uncompressing...\n") + ( (100.0*current)/total ).toFixed(1) + "%";
                            progressValue = (current*100.0)/total;
                        }
                        
                        onCreationCompleted: {
                            app.deflationDone.connect(cpc.finish);
                            app.archiveDeflationProgress.connect(onDeflationProgressChanged);
                            mushaf.deflationProgress.connect(onDeflationProgressChanged);
                            mushaf.deflationDone.connect(cpc.finish);
                        }
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
                            object.parentControl = contentContainer;
                            object.triggered.connect(root.finish);
                        }
                    }
                }
            ]
        }
    }
}