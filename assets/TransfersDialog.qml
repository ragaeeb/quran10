import bb.cascades 1.3

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
            
            onCreationCompleted: {
                open();
                queue.queueCompleted.connect(onComplete);
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
                listView.scrollToItem([queue.currentIndex]);
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
                        }
                        
                        Container
                        {
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            visible: queue.queued > 0
                            topPadding: offliner.delegateActive ? ui.sdu(4.25) : 0
                            
                            OfflineDelegate
                            {
                                id: offliner
                                delegateActive: !reporter.online
                                graphic: "images/toast/ic_offline.png"
                                bottomMargin: 10
                            }
                            
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
                                    if (data.busy) {
                                        return "busy";
                                    } else if (data.tafsirPath) {
                                        return "tafsir";
                                    } else if (data.tafsirPath) {
                                        return "translation";
                                    } else if (data.mushaf || data.mushafSizeFetch) {
                                        return "mushaf";
                                    } else if (data.recitation) {
                                        return "recitation";
                                    } else if (data.updateCheck) {
                                        return "updateCheck";
                                    } else if (data.geoLookup) {
                                        return "geoLookup";
                                    } else if (data.localUri) {
                                        return "mushafPage";
                                    } else if (data.joinDownload || data.ayatImages) {
                                        return "overlay";
                                    } else if (data.google_search) {
                                        return "google_search";
                                    } else {
                                        return "transfer";
                                    }
                                }
                                
                                listItemComponents: [
                                    ListItemComponent
                                    {
                                        type: "busy"
                                        
                                        TransferListItem
                                        {
                                            imageSource: "images/list/ic_clock.png"
                                            description: ListItemData.busy
                                            
                                            ListItem.onInitializedChanged: {
                                                if (initialized) {
                                                    ft.play();
                                                }
                                            }
                                            
                                            animations: [
                                                SequentialAnimation
                                                {
                                                    id: ft
                                                    repeatCount: AnimationRepeatCount.Forever
                                                    
                                                    FadeTransition
                                                    {
                                                        fromOpacity: 1
                                                        toOpacity: 0.5
                                                        easingCurve: StockCurve.SineIn
                                                        duration: 500
                                                    }
                                                    
                                                    FadeTransition
                                                    {
                                                        fromOpacity: 0.5
                                                        toOpacity: 1
                                                        easingCurve: StockCurve.SineOut
                                                        duration: 500
                                                    }
                                                }
                                            ]
                                        }
                                    },
                                    
                                    ListItemComponent
                                    {
                                        type: "google_search"
                                        
                                        TransferListItem {
                                            successImageSource: "images/menu/ic_search.png"
                                        }
                                    },
                                    
                                    ListItemComponent
                                    {
                                        type: "tafsir"
                                        
                                        TransferListItem {
                                            successImageSource: "images/list/ic_tafsir.png"
                                        }
                                    },
                                    
                                    ListItemComponent
                                    {
                                        type: "translation"
                                        
                                        TransferListItem {
                                            successImageSource: "images/list/ic_translation.png"
                                        }
                                    },
                                    
                                    ListItemComponent
                                    {
                                        type: "overlay"
                                        
                                        TransferListItem {
                                            successImageSource: "images/list/ic_overlay.png"
                                        }
                                    },
                                    
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
                                        type: "geoLookup"
                                        
                                        TransferListItem {
                                            successImageSource: "images/list/ic_geo_search.png"
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