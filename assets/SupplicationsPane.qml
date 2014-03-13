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
        titleBar: QuranTitleBar {}
        
        Container
        {
            background: back.imagePaint
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            ListView
            {
                id: listView
                
                dataModel: ArrayDataModel {
                    id: theDataModel
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        StandardListItem {
                            title: ListItemData.english_name
                            description: ListItemData.arabic_name
                            status: ListItemData.verse_id
                            imageSource: "images/ic_quran.png"
                        }
                    }
                ]
                
                onTriggered: {
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
                        theDataModel.append(data);
                    }
                }
                
                onCreationCompleted: {
                    helper.dataLoaded.connect(onDataLoaded);
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
                    imageSource: "images/background.png"
                }
            ]
        }
    }
}