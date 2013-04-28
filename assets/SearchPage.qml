import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    Container
    {
        TextField
        {
            hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
            
            onTextChanging: {
                if (text.length > 2) {
                    var translation = persist.getValueFor("translation")
                    var translationClause = ""
                    var translationLike = ""

                    if (translation != "") {
                        translationClause = "," + translation + " as translation"
                        translationLike = " OR "+translation+" LIKE '%"+text+"%'"
                    }

                    sqlDataSource.query = "SELECT arabic,surah_id,verse_id" + translationClause + " FROM quran WHERE arabic like '%"+text+"%'"+translationLike
                    sqlDataSource.load()
                } else if (text.length == 0) {
                    theDataModel.clear()
                }
            }

            attachedObjects: [
                CustomSqlDataSource {
                    id: sqlDataSource
                    source: "app/native/assets/dbase/quran.db"
                    name: "search"

                    onDataLoaded: {
	                    theDataModel.clear()
	                    console.log("DATA FOUND", data[0].surah_id, data[0].verse_id, data[0].translation)
	                    theDataModel.insertList(data)
                    }
                }
            ]
        }
        
        ListView
        {
            id: listView

            dataModel: GroupDataModel {
                id: theDataModel
                sortingKeys: ["surah_id","verse_id"]
                grouping: ItemGrouping.ByFullValue
            }
            
            listItemComponents: [
                
                ListItemComponent {
                    type: "header"

                    Container {
                        id: headerRoot
                        horizontalAlignment: HorizontalAlignment.Fill
                        topPadding: 5; bottomPadding: 5; leftPadding: 5
                        
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }

                        Label {
                            text: qsTr("%1").arg(ListItemData)
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.fontSize: FontSize.XXSmall
                            textStyle.color: Color.White
                            textStyle.fontWeight: FontWeight.Bold
                            textStyle.textAlign: TextAlign.Center
                            
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                        }
                    }
                },
                
                ListItemComponent {
                    type: "item"
                    
                    Container
                    {
                        topPadding: 5; bottomPadding: 5; leftPadding: 5; rightPadding: 5
                        horizontalAlignment: HorizontalAlignment.Fill
                        preferredWidth: 1280
                        
                        Label {
                            id: firstLabel
                            text: ListItemData.arabic
                            multiline: true
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.color: Color.White
                            textStyle.textAlign: TextAlign.Center
                        }
                        
                        Label {
                            id: translationLabel
                            text: ListItemData.translation
                            multiline: true
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.color: Color.White
                            textStyle.textAlign: TextAlign.Center
                        }
                    }
                }
            ]
        }
    }
}