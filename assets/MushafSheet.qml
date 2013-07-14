import bb.cascades 1.0
import bb.system 1.0
import QtQuick 1.0

Sheet
{
    id: sheet
    
    Page
    {
        id: mainPage
        actionBarVisibility: ChromeVisibility.Hidden
        
        titleBar: TitleBar
        {
            id: hiddenTitle
            visibility: ChromeVisibility.Hidden
            title: qsTr("Page %1").arg(scroller.firstVisibleItem[0]+1)
            
            dismissAction: ActionItem {
                title: qsTr("Back") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    sheet.close();
                }
            }
            
            attachedObjects: [
                Timer {
                    id: timer
                    repeat: false
                    interval: 3000
                    
                    onTriggered: {
                        hiddenTitle.visibility = ChromeVisibility.Hidden
                        mainPage.actionBarVisibility = ChromeVisibility.Hidden
                    }
                }
            ]
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            onCreationCompleted:
            {
                if (app.mushafReady) {
                    adm.append( app.getMushafPages() );
                } else if (mushafQueue.queued == 0) {
                    adm.append( app.getDownloadedMushafPages() );
                    prompt.show();
                } else {
                    adm.append( app.getDownloadedMushafPages() );
                }
            }
            
            ControlDelegate
            {
                delegateActive: !app.mushafReady
                horizontalAlignment: HorizontalAlignment.Fill
                
                sourceComponent: ComponentDefinition
                {
                    ProgressIndicator {
                        horizontalAlignment: HorizontalAlignment.Fill
                        fromValue: 0
                        toValue: 614
                        value: mushafQueue.queued
                    }
                }
            }
            
            ListView
            {
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                onTouch: {
                    hiddenTitle.visibility = ChromeVisibility.Overlay;
                    mainPage.actionBarVisibility = ChromeVisibility.Overlay;
                    timer.restart();
                }
                
                layout: StackListLayout {
                    orientation: LayoutOrientation.RightToLeft
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        ScrollView {
                            id: rootItem
                            property variant data: ListItemData
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            scrollViewProperties.pinchToZoomEnabled: true
                            scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.OnPinch
                            
                            onDataChanged: {
                                resetViewableArea();
                            }
                            
                            ImageView {
                                id: root
                                imageSource: ListItemData
                                scalingMethod: ScalingMethod.AspectFit
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Fill
                            }
                        }
                    }
                ]
                
                attachedObjects: [
                    ListScrollStateHandler {
                        id: scroller
                    }
                ]
            }
            
            attachedObjects: [
                SystemDialog {
                    id: prompt
                    title: qsTr("Confirmation") + Retranslate.onLanguageChanged
                    body: qsTr("We are about to download the mushaf (which is about ~200MB in size), you should only attempt to do this if you have either an unlimited data plan, or are connected via Wi-Fi. Otherwise you might incur a lot of data charges. Are you sure you want to continue? If you select No you can always attempt to download again later.") + Retranslate.onLanguageChanged
                    confirmButton.label: qsTr("Yes") + Retranslate.onLanguageChanged
                    cancelButton.label: qsTr("No") + Retranslate.onLanguageChanged
                    
                    function onMushafPageReady(imageSource) {
                        adm.append(imageSource);
                    }
                    
                    onFinished: {
                        if (result == SystemUiResult.ConfirmButtonSelection) {
                            app.mushafPageReady.connect(onMushafPageReady);
                            app.downloadMushaf();
                            
                            var abort = abortDownloadAction.createObject();
                            mainPage.addAction(abort, ActionBarPlacement.Default);
                        } else {
                            if ( adm.isEmpty() ) {
                                sheet.close();   
                            }
                        }
                    }
                },
                
                ComponentDefinition
                {
                    id: abortDownloadAction
                    
                    DeleteActionItem {
                        title: qsTr("Abort") + Retranslate.onLanguageChanged
                        imageSource: "images/ic_cancel.png"
                        
                        onTriggered: {
                            mushafQueue.abort();
                        }
                    }
                }
            ]
        }
    }
    
    onClosed: {
        destroy();
    }
}