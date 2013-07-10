import bb.cascades 1.0
import QtQuick 1.0

Sheet
{
    id: sheet
    
    Page
    {
        id: mainPage
        
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
                    }
                }
            ]
        }

        ListView
        {
            dataModel: ArrayDataModel {
                id: adm
            }
            
            onTouch: {
                hiddenTitle.visibility = ChromeVisibility.Overlay
                timer.restart();
            }
            
            onCreationCompleted: {
                var str = "" + 1
                var pad = "000"
                
                for (var i = 1; i <= 614; i++) {
                    var str = ""+i;
                    var padded = pad.substring(0, pad.length - str.length) + str;
                    adm.append( "images/mushaf/%1.jpg".arg(padded) );
                }
            }
            
            layout: StackListLayout {
                orientation: LayoutOrientation.RightToLeft
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    ImageView
                    {
                        id: root
                        imageSource: ListItemData
                        scalingMethod: ScalingMethod.AspectFit

                        gestureHandlers: [
                            PinchHandler {
                                onPinchUpdated: {
                                    root.scaleX = root.scaleY = event.pinchRatio;
                                }
                            },
                            
                            DoubleTapHandler {
                                onDoubleTapped: {
                                    root.scaleX = root.scaleY = 1;
                                    root.translationY = 0;
                                }
                            }
                        ]
                    }
                }
            ]
            
            attachedObjects: [
                ListScrollStateHandler {
                    id: scroller
                }
            ]
        }
    }
    
    onClosed: {
        destroy();
    }
}