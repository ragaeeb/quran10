import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: root
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property int chapterNumber
    
    onChapterNumberChanged: {
        helper.fetchAllTafsirForChapter(root, chapterNumber);
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchTafsirForSurah)
        {
            adm.append(data);
            
            emptyDelegate.delegateActive = adm.isEmpty();
            listView.visible = !emptyDelegate.delegateActive;
            
            if (data.length == 1) {
                listView.triggered([0]);
            }
        }
    }
    
    titleBar: ChapterTitleBar {
        chapterNumber: root.chapterNumber
    }
    
    Container
    {
        background: tafseerBackground.imagePaint
        layout: DockLayout {}
        
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: Color.Black
            opacity: 0.7
        }
        
        EmptyDelegate
        {
            id: emptyDelegate
            graphic: "images/placeholders/empty_tafsir.png"
            labelText: qsTr("No tafsir found for that chapter.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                console.log("UserEvent: EmptyChapterTafsirsTriggered");
            }
        }
        
        ListView
        {
            id: listView
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        id: rootItem
                        title: ListItem.data.author
                        description: ListItem.data.title
                        imageSource: "images/list/ic_chapter_tafsir.png"
                    }
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: ChapterTafsirPicked");

                definition.source = "AyatTafsirDialog.qml";
                var htd = definition.createObject();
                htd.suitePageId = dataModel.data(indexPath).id;
                htd.open();
            }
        }
    }
    
    attachedObjects: [
        ImagePaintDefinition
        {
            id: tafseerBackground
            imageSource: "images/backgrounds/tafseer_picker_bg.png"
        }
    ]
}