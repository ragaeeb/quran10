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
                
                dataModel: GroupDataModel {
                    id: theDataModel
                    grouping: ItemGrouping.ByFullValue
                    sortingKeys: ["english_name"]
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        type: "header"
                        
                        Header {
                            title: ListItemData
                            subtitle: ListItem.sectionSize
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "item"
                        
                        StandardListItem {
                            title: ListItemData.english_name
                            description: ListItemData.arabic_name
                            status: ListItemData.verse_id
                            imageSource: "images/list/ic_supplication.png"
                        }
                    }
                ]
                
                onTriggered: {
                    console.log("UserEvent: SupplicationItem");
                    var data = dataModel.data(indexPath);
                    
                    definition.source = "SurahPage.qml";
                    var sp = definition.createObject();
                    navigationPane.push(sp);
                    sp.surahId = data.surah_id;
                    sp.requestedVerse = data.verse_id;
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllDuaa)
                    {
                        theDataModel.clear();
                        theDataModel.insertList(data);
                        
                        if ( persist.tutorial( "tutorialSupplications", qsTr("These are the various duaa that are found throughout the Qu'ran."), "asset:///images/tabs/ic_supplications.png" ) ) {}
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