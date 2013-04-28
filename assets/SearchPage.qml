import bb.cascades 1.0
import com.canadainc.data 1.0

BasePage
{
    contentContainer: Container
    {
        TextField
        {
            id: searchField
            hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
            
            input {
                submitKey: SubmitKey.Submit
                
                onSubmitted: {
                    var translation = persist.getValueFor("translation")
                    var translationClause = ""
                    var translationLike = ""

                    if (translation != "") {
                        translationClause = ",quran." + translation + " as translation"
                        translationLike = " OR quran."+translation+" LIKE '%"+text+"%'"
                    }

					busy.running = true
                    sqlDataSource.query = "SELECT chapters.english_name,quran.arabic,quran.surah_id,quran.verse_id" + translationClause + " FROM quran,chapters WHERE arabic like '%"+text+"%'"+translationLike+" AND quran.surah_id=chapters.surah_id"
                    sqlDataSource.load()
                }
            }

            attachedObjects: [
                CustomSqlDataSource {
                    id: sqlDataSource
                    source: "app/native/assets/dbase/quran.db"
                    name: "search"

                    onDataLoaded: {
	                    theDataModel.clear()
	                    theDataModel.insertList(data)
	                    busy.running = false
                    }
                }
            ]
        }
        
        ActivityIndicator {
            id: busy
            running: false
            visible: running
            preferredHeight: 250
            horizontalAlignment: HorizontalAlignment.Center
        }
        
        ListView
        {
        	property alias background: bg
            id: listView
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: bg
                    imageSource: "asset:///images/header_bg.png"
                }
            ]

            dataModel: GroupDataModel {
                id: theDataModel
                sortingKeys: ["english_name","verse_id"]
                grouping: ItemGrouping.ByFullValue
            }
            
            listItemComponents: [
                
                ListItemComponent {
                    type: "header"

                    Container {
                        id: headerRoot
                        horizontalAlignment: HorizontalAlignment.Fill
                        topPadding: 5; bottomPadding: 5; leftPadding: 5
                        background: ListItem.view.background.imagePaint
                        
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }

                        Label {
                            text: ListItemData
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