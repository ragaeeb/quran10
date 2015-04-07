import bb.cascades 1.3

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
                queue.isBlockedChanged.connect(root.finish);
            }
            
            function finish()
            {
                if ( !queue.isBlocked && !out.isPlaying() ) {
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
                        minHeight: ui.sdu(25)
                        minWidth: ui.sdu(37.5)
                        maxHeight: ui.sdu(50)
                        maxWidth: ui.sdu(75)
                        rightPadding: 30
                        translationX: ui.sdu(50)
                        bottomPadding: 20
                        layout: DockLayout {}
                        
                        animations: [
                            TranslateTransition {
                                id: tt
                                fromX: ui.sdu(50)
                                toX: 0
                                easingCurve: StockCurve.ExponentialOut
                                delay: 250
                                duration: 750
                            },
                            
                            TranslateTransition
                            {
                                id: out
                                fromX: 0
                                toX: ui.sdu(50)
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
                            topPadding: ui.sdu(3.75)
                            
                            EmptyDelegate
                            {
                                delegateActive: queue.queued == 0
                                graphic: "images/placeholders/empty_downloads.png"
                                labelText: qsTr("No downloads queued or active yet.") + Retranslate.onLanguageChanged
                            }
                            
                            OfflineDelegate
                            {
                                delegateActive: !reporter.online
                                graphic: "images/toast/ic_offline.png"
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
                                maxWidth: ui.sdu(75)
                                maxHeight: ui.sdu(50)
                                scrollRole: ScrollRole.Main
                                
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
                                    } else if (data.updateCheck) {
                                        return "updateCheck";
                                    } else if (data.geoLookup) {
                                        return "geoLookup";
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
                                        type: "geoLookup"
                                        
                                        TransferListItem {
                                            successImageSource: "images/list/ic_geo_search.png"
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
                                    },
                                    
                                    ListItemComponent
                                    {
                                        type: "updateCheck"
                                        
                                        TransferListItem {
                                            successImageSource: "images/list/ic_update_check.png"
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
                            cpc.visible = true;
                            labelText = qsTr("Uncompressing...\n") + ( (100.0*current)/total ).toFixed(1) + "%";
                            progressValue = (current*100.0)/total;
                        }
                        
                        function onDeflationDone(result) {                            
                            cpc.finish();
                        }
                        
                        onCreationCompleted: {
                            offloader.deflationDone.connect(onDeflationDone);
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