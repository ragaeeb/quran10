import bb.cascades 1.0
import com.canadainc.data 1.0

Container
{
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    property real ratio: 0.4
    property real screenHeight: 1280
    
    function applyData(data)
    {
        adm.clear();
        adm.append(data);
        
        relatedHeader.subtitle = data.length;
    }
    
    onCreationCompleted: {
        persist.tutorial( "tutorialRelatedExpand", qsTr("You can expand this top section by tapping on the 'Related' header. To minimize it, tap on the hadith header at the bottom pane."), "asset:///images/dropdown/similar.png" );
    }
    
    Header {
        id: relatedHeader
        title: qsTr("Related") + Retranslate.onLanguageChanged
        
        gestureHandlers: [
            TapHandler
            {
                onTapped: {
                    ratio = 0.7;
                }
            }
        ]
    }
    
    ListView
    {
        id: similarList
        maxHeight: screenHeight*ratio
        property variant appRef: app
        property int unlinkIndex: -1
        
        dataModel: ArrayDataModel {
            id: adm
        }
        
        function onDataLoaded(id, data)
        {
            if (id == QueryId.UnlinkNarrationFromSimilar)
            {
                persist.showToast( qsTr("Naration unlinked, it should no longer show up under the Similar option."), "", "asset:///images/menu/ic_unlink.png" );
                
                if (unlinkIndex >= 0)
                {
                    adm.removeAt(unlinkIndex);
                    
                    unlinkIndex = -1;
                }
            }
        }
        
        function unlink(indexPath)
        {
            var data = adm.data(indexPath);
            helper.unlinkNarrationFromSimilar(similarList, data.id);
            unlinkIndex = indexPath[0];
            var similar = root.similarNarrations;
            similar.splice(unlinkIndex,1);
            root.similarNarrations = similar;
        }
        
        listItemComponents: [
            ListItemComponent
            {
                Container
                {
                    id: itemRoot
                    leftPadding: 10; rightPadding: 10
                    
                    Label
                    {
                        id: body
                        content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                        multiline: true
                        //textStyle.base: collections.textFont
                        text: "%1\n\n(%2 #%3)\n".arg(ListItemData.hadithText).arg( collections.renderAppropriate(ListItemData.collection) ).arg(ListItemData.hadithNumber)
                    }
                    
                    ImageView {
                        imageSource: "images/dividers/divider_similar.png"
                        horizontalAlignment: HorizontalAlignment.Center
                        visible: itemRoot.ListItem.indexInSection < itemRoot.ListItem.sectionSize-1
                    }
                    
                    contextActions: [
                        ActionSet
                        {
                            title: collections.renderAppropriate(ListItemData.collection)
                            subtitle: ListItemData.hadithNumber
                            
                            DeleteActionItem
                            {
                                imageSource: "images/menu/ic_unlink.png"
                                title: qsTr("Unlink") + Retranslate.onLanguageChanged
                                
                                onTriggered: {
                                    console.log("UserEvent: UnlinkNarrationFromOthers");
                                    itemRoot.ListItem.view.unlink(itemRoot.ListItem.indexPath);
                                }
                            }
                        }
                    ]
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