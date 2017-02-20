import bb.cascades 1.2
import com.canadainc.data 1.0

ResizableContainer
{
    headerTitle: qsTr("Related") + Retranslate.onLanguageChanged
    
    function applyData(data, bodyControl)
    {
        adm.clear();
        adm.append(data);
        
        headerSubtitle = data.length;
        searchDecorator.decorateSimilar(data, adm, bodyControl, "content");
        
        tutorial.execBelowTitleBar( "relatedExpand", qsTr("You can expand this top section by tapping on the 'Related' header.") );
        tutorial.exec( "relatedExpand2", qsTr("To minimize it, tap on the ayat header on the bottom pane."), HorizontalAlignment.Center, VerticalAlignment.Center, 0, 0, tutorial.du(12) );
    }
    
    ListView
    {
        id: similarList
        maxHeight: screenHeight*ratio
        property bool showTranslation: helper.showTranslation
        scrollRole: ScrollRole.Main
        
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
                        textStyle.base: itemRoot.ListItem.view.showTranslation ? SystemDefaults.TextStyles.BodyText : global.textFont
                        text: ListItemData.content
                    }
                    
                    Label {
                        content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                        text: "(%1 %2:%3)\n".arg(ListItemData.name).arg(ListItemData.surah_id).arg(ListItemData.verse_id)
                        
                        activeTextHandler: ActiveTextHandler
                        {
                            onTriggered: {
                                var ayatPage = Qt.launch("AyatPage.qml");
                                ayatPage.surahId = ListItemData.surah_id;
                                ayatPage.verseId = ListItemData.verse_id;
                                
                                event.abort();
                            }
                        }
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
        SearchDecorator {
            id: searchDecorator
        }
    ]
}