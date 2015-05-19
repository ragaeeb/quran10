import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: root
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property int chapterNumber
    
    onChapterNumberChanged: {
        helper.fetchAllTafsirForChapter(root, chapterNumber);
        helper.fetchSurahHeader(root, chapterNumber);
        
        reporter.record("ChapterTafsirPicker", chapterNumber);
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchTafsirForSurah)
        {
            adm.append(data);
            offloader.decorateTafsir(adm, "images/list/ic_chapter_tafsir.png");
            
            emptyDelegate.delegateActive = adm.isEmpty();
            listView.visible = !emptyDelegate.delegateActive;
            
            if (data.length == 1) {
                listView.triggered([0]);
            }
        } else if (id == QueryId.FetchSurahHeader) {
            titleBar.title = qsTr("%1 Tafsir").arg(helper.showTranslation ? data[0].transliteration : data[0].name);
        }
    }
    
    titleBar: TitleBar {}
    
    Container
    {
        background: tafseerBackground.imagePaint
        layout: DockLayout {}
        
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: Color.Black
            opacity: 0.4
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
            scrollRole: ScrollRole.Main
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        id: rootItem
                        title: ListItemData.author
                        description: ListItemData.heading && ListItemData.heading.length > 0 ? ListItemData.heading : ListItemData.title
                        imageSource: ListItemData.imageSource
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
            imageSource: "images/backgrounds/bg_chapter_tafsir_picker.amd"
        }
    ]
    
    function reload() {
        chapterNumberChanged();
    }
    
    function cleanUp() {
        helper.textualChange.disconnect(reload);
    }
    
    onCreationCompleted: {
        helper.textualChange.connect(reload);
    }
}