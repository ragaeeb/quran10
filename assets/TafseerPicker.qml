import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: root
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property int chapterNumber
    property int verseNumber: -1
    
    function onDataLoaded(id, data)
    {
        adm.append(data);
        
        emptyDelegate.delegateActive = adm.isEmpty();
        listView.visible = !emptyDelegate.delegateActive;
        
        if ( adm.size() == 1 ) {
            navigationPane.remove(root);
            tafsirPicked([0]);
        }
    }
    
    function tafsirPicked(indexPath)
    {
        var item = adm.data(indexPath);
        var id = item.id;
        var page
        
        if (id == 0) {
            definition.source = "TafseerIbnKatheer.qml";
            page = definition.createObject();
            page.surahId = chapterNumber;
        } else {
            definition.source = "TafseerPage.qml";
            page = definition.createObject();
            page.tafsirId = id;
        }
        
        navigationPane.push(page);
    }
    
    onVerseNumberChanged: {
        if (verseNumber > 0) {
            helper.fetchTafsirForAyat(root, chapterNumber, verseNumber);
        } else {
            adm.append({'id': 0, 'description': 'Ibn Katheer Tafsir'});
            helper.fetchTafsirForSurah(root, chapterNumber);
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
            opacity: 0.5
        }
        
        EmptyDelegate
        {
            id: emptyDelegate
            graphic: "images/placeholders/empty_tafsir.png"
            labelText: verseNumber > 0 ? qsTr("No tafsir found for that specific verse.") + Retranslate.onLanguageChanged : qsTr("No tafsir found for that chapter.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                console.log("UserEvent: Empty Templates Triggered");
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
                        title: ListItemData.description
                        imageSource: "images/menu/ic_tafsir_show.png"
                    }
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: Tafsir Picked");
                tafsirPicked(indexPath);
            }
        }
        
        attachedObjects: [
            ImagePaintDefinition
            {
                id: tafseerBackground
                imageSource: "images/backgrounds/tafseer_picker_bg.png"
            },
            
            ComponentDefinition {
                id: definition
            }
        ]
    }
}