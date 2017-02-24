import bb.cascades 1.2

Delegate
{
    id: delegateRoot
    
    function onQueueChanged()
    {
        if (object) {
            object.preventExit();
        }
        
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
            
            function preventExit()
            {
                if ( out.isPlaying() )
                {
                    out.stop();
                    tt.play();
                }
            }
            
            function onComplete()
            {
                if (reporter.online) {
                    finish();
                }
            }
            
            function onIndexChanged() {
                listView.scrollToItem([queue.currentIndex]);
            }
            
            onCreationCompleted: {
                open();
                queue.queueCompleted.connect(onComplete);
                queue.isBlockedChanged.connect(root.finish);
                queue.currentIndexChanged.connect(onIndexChanged);
            }
            
            function finish()
            {
                if ( !queue.isBlocked && !out.isPlaying() ) {
                    out.play();
                }
            }
            
            onOpened: {
                tt.play();
                onIndexChanged();
                dialogContainer.opacity = 1;
            }
            
            onClosed: {
                queue.queueCompleted.disconnect(onComplete);
                queue.isBlockedChanged.disconnect(root.finish);
                queue.currentIndexChanged.disconnect(onIndexChanged);
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
                        minHeight: tutorial.du(25)
                        minWidth: tutorial.du(37.5)
                        maxHeight: tutorial.du(50)
                        maxWidth: tutorial.du(75)
                        rightPadding: 30
                        translationX: tutorial.du(50)
                        bottomPadding: 20
                        layout: DockLayout {}
                        
                        animations: [
                            TranslateTransition {
                                id: tt
                                fromX: tutorial.du(50)
                                toX: 0
                                easingCurve: StockCurve.ExponentialOut
                                delay: 250
                                duration: 750
                            },
                            
                            TranslateTransition
                            {
                                id: out
                                fromX: 0
                                toX: tutorial.du(50)
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
                            topPadding: tutorial.du(3.75)
                            
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
                            topPadding: offliner.delegateActive ? tutorial.du(6) : 0
                            
                            OfflineDelegate
                            {
                                id: offliner
                                delegateActive: !reporter.online
                                bottomMargin: 10
                            }
                            
                            Header {
                                subtitle: queue.queued
                                title: qsTr("Download Queue") + Retranslate.onLanguageChanged
                            }
                            
                            ListView
                            {
                                id: listView
                                maxWidth: tutorial.du(75)
                                maxHeight: tutorial.du(50)
                                scrollRole: ScrollRole.Main
                                
                                onCreationCompleted: {
                                    dataModel = queue.model;
                                }
                                
                                function itemType(data, indexPath)
                                {
                                    if (data.mushaf) {
                                        return "mushaf";
                                    } else if (data.recitation) {
                                        return "recitation";
                                    } else if (data.localUri) {
                                        return "mushafPage";
                                    } else {
                                        return "transfer";
                                    }
                                }
                                
                                listItemComponents: [
                                    ListItemComponent
                                    {
                                        type: "mushaf"
                                        
                                        TransferListItem {
                                            successImageSource: "images/list/ic_mushaf.png"
                                        }
                                    },
                                    
                                    ListItemComponent
                                    {
                                        type: "mushafPage"
                                        
                                        TransferListItem {
                                            successImageSource: "images/list/ic_mushaf_page.png"
                                        }
                                    },
                                    
                                    ListItemComponent
                                    {
                                        type: "recitation"
                                        
                                        TransferListItem {
                                            successImageSource: "images/list/transfer_recitation.png"
                                        }
                                    },
                                    
                                    ListItemComponent
                                    {
                                        type: "transfer"
                                        
                                        TransferListItem {
                                            successImageSource: "images/tabs/ic_transfers.png"
                                        }
                                    }
                                ]
                            }
                        }
                    }
                }
            }
            
            attachedObjects: [
                OrientationHandler {
                    id: rotationHandler
                    
                    onOrientationChanged: {
                        contentContainer.maxHeight = orientation == UIOrientation.Portrait ? deviceUtils.pixelSize.height-150 : deviceUtils.pixelSize.width-150;
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