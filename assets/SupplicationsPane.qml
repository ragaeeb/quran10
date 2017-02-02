import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    Page
    {
        id: mainPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: TitleBar {
            title: qsTr("Supplications") + Retranslate.onLanguageChanged
            scrollBehavior: TitleBarScrollBehavior.NonSticky
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}
            
            ListView
            {
                id: listView
                scrollRole: ScrollRole.Main
                
                dataModel: GroupDataModel
                {
                    id: theDataModel
                    grouping: ItemGrouping.ByFullValue
                    sortingKeys: ["surah_id","verse_number_start"]
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        type: "header"
                        
                        Header {
                            title: global.getHeaderData(ListItem).name
                            subtitle: ListItem.view.dataModel.childCount(ListItem.indexPath)
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "item"
                        
                        StandardListItem {
                            title: ListItemData.name
                            description: ListItemData.body
                            status: ListItemData.verse_number_start+"-"+ListItemData.verse_number_end
                            imageSource: "images/list/ic_supplication.png"
                        }
                    }
                ]
                
                function onPicked(surahId, verseId)
                {
                    var ayatPage = Qt.launch("AyatPage.qml");
                    ayatPage.surahId = surahId;
                    ayatPage.verseId = verseId;
                }
                
                onTriggered: {
                    console.log("UserEvent: SupplicationItem");
                    
                    if (indexPath.length > 1)
                    {
                        var data = dataModel.data(indexPath);
                        
                        var sp = Qt.launch("SurahPage.qml");
                        sp.picked.connect(onPicked);
                        sp.surahId = data.surah_id;
                        sp.verseId = data.verse_number_start;
                        
                        reporter.record("SupplicationTriggered", data.surah_id+":"+data.verse_number_start);
                    }
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllDuaa)
                    {
                        theDataModel.clear();
                        theDataModel.insertList(data);
                        Qt.navigationPane.parent.unreadContentCount = data.length;
                        
                        deviceUtils.attachTopBottomKeys(mainPage, listView, true);
                        tutorial.exec( "tapSupplication", qsTr("These are some of the supplications found throughout the Qu'ran. Tap on any one of them to open it."), HorizontalAlignment.Center, VerticalAlignment.Center, 0, 0, 0, 0, undefined, "d" );
                    }
                }
            }
        }
    }
    
    function reload() {
        helper.fetchAllDuaa(listView);
    }
    
    function cleanUp() {
        helper.textualChange.disconnect(reload);
    }
    
    onCreationCompleted: {
        reload();
        helper.textualChange.connect(reload);
    }
}