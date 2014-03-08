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
                
                onCreationCompleted: {
                    sql.query = "select supplications.surah_id,supplications.verse_id,chapters.english_name,chapters.arabic_name FROM supplications INNER JOIN chapters ON supplications.surah_id=chapters.surah_id";
                    sql.load();
                }
                
                attachedObjects: [
                    ComponentDefinition {
                        id: definition
                    },
                    
                    CustomSqlDataSource {
                        id: sql
                        source: "app/native/assets/dbase/quran.db"
                        name: "supplications"
                        
                        onDataLoaded: {
                            theDataModel.clear();
                            theDataModel.append(data);
                        }
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