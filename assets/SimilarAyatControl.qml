import bb.cascades 1.0

ResizableContainer
{
    headerTitle: qsTr("Related") + Retranslate.onLanguageChanged
    
    onCreationCompleted: {
        persist.tutorial( "tutorialRelatedExpand", qsTr("You can expand this top section by tapping on the 'Related' header. To minimize it, tap on the hadith header at the bottom pane."), "asset:///images/dropdown/similar.png" );
    }
    
    function applyData(data, bodyControl)
    {
        adm.clear();
        adm.append(data);
        
        headerSubtitle = data.length;
        
        app.decorateSimilarResults(data, bodyControl.value, adm, bodyControl);
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
}