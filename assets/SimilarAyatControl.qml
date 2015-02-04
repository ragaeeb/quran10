import bb.cascades 1.0
import com.canadainc.data 1.0

Container
{
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    property real ratio: 0.4
    property real screenHeight: 1280
    
    function applyData(data, mainText)
    {
        adm.clear();
        adm.append(data);
        
        relatedHeader.subtitle = data.length;
        
        app.decorateSimilarResults(data, mainText, adm);
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
        
        dataModel: ArrayDataModel {
            id: adm
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
                        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                        multiline: true
                        textStyle.base: global.textFont
                        text: ListItemData.content
                    }
                    
                    Label {
                        content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                        text: "(%1 %2:%3)\n".arg(ListItemData.name).arg(ListItemData.surah_id).arg(ListItemData.verse_id)
                    }
                    
                    ImageView {
                        imageSource: "images/dividers/divider_similar.png"
                        horizontalAlignment: HorizontalAlignment.Center
                        visible: itemRoot.ListItem.indexInSection < itemRoot.ListItem.sectionSize-1
                    }
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