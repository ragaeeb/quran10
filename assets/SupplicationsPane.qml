import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        id: mainPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: TitleBar {
            title: qsTr("Supplications") + Retranslate.onLanguageChanged
        }
        
        Container
        {
            background: back.imagePaint
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            ListView
            {
                id: listView
                scrollRole: ScrollRole.Main
                
                dataModel: GroupDataModel {
                    id: theDataModel
                    grouping: ItemGrouping.ByFullValue
                    sortingKeys: ["surah_id","verse_number_start"]
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        type: "header"
                        
                        Header {
                            title: ListItemData
                            subtitle: ListItem.view.dataModel.childCount(ListItem.indexPath)
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "item"
                        
                        StandardListItem {
                            title: ListItemData.transliteration ? ListItemData.transliteration : qsTr("Chapter %1").arg(ListItemData.surah_id)
                            description: ListItemData.name
                            status: ListItemData.verse_number_start
                            imageSource: "images/list/ic_supplication.png"
                        }
                    }
                ]
                
                function onPicked(surahId, verseId)
                {
                    definition.source = "AyatPage.qml";
                    var ayatPage = definition.createObject();
                    ayatPage.surahId = surahId;
                    ayatPage.verseId = verseId;

                    navigationPane.push(ayatPage);
                }
                
                onTriggered: {
                    console.log("UserEvent: SupplicationItem");
                    
                    if (indexPath.length > 1)
                    {
                        var data = dataModel.data(indexPath);
                        
                        definition.source = "SurahPage.qml";
                        var sp = definition.createObject();
                        sp.picked.connect(onPicked);
                        navigationPane.push(sp);
                        sp.fromSurahId = data.surah_id;
                        sp.toSurahId = data.surah_id;
                        sp.requestedVerse = data.verse_number_start;
                    }
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllDuaa)
                    {
                        theDataModel.clear();
                        theDataModel.insertList(data);
                        navigationPane.parent.unreadContentCount = data.length;
                        
                        if ( persist.tutorial( "tutorialSupplications", qsTr("These are the various duaa that are found throughout the Qu'ran."), "asset:///images/tabs/ic_supplications.png" ) ) {}
                        
                        deviceUtils.attachTopBottomKeys(mainPage, listView, true);
                    }
                }
                
                onCreationCompleted: {
                    helper.fetchAllDuaa(listView);
                }
                
                attachedObjects: [
                    ComponentDefinition {
                        id: definition
                    }
                ]
            }
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: back
                    imageSource: "images/backgrounds/background.png"
                }
            ]
        }
    }
}