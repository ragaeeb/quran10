import bb.cascades 1.0
import com.canadainc.data 1.0

BasePage
{
    paneProperties: NavigationPaneProperties {
        property variant navPane: navigationPane
        id: properties
    }
    
    contentContainer: Container
    {
        TextField
        {
		    onCreationCompleted: {
                translate.play();
            }
            
            id: searchField
            hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
            bottomMargin: 0
            horizontalAlignment: HorizontalAlignment.Fill

            animations: [
	            TranslateTransition {
	                id: translate
	                fromY: 1000
	                duration: 500
	                
	                onEnded: {
	                    searchField.requestFocus()
	                }
	            }
	        ]
            
            input {
                submitKey: SubmitKey.Submit
                
                onSubmitted:
                {
                    var trimmedText = text.replace(/^\s+|\s+$/g,"");
                    
                    if (trimmedText.length > 1)
                    {
	                    theDataModel.clear()
	                    sqlDataSource.translationLoaded = sqlDataSource.arabicLoaded = false
	                    
	                    busy.running = true
	                    
	                    var translation = persist.getValueFor("translation")
	
	                    if (translation != "") {
	                    	sqlDataSource.query = "select %1.surah_id,%1.verse_id,%1.text,chapters.english_name as name, chapters.english_name, chapters.arabic_name, chapters.english_translation from %1 INNER JOIN chapters on chapters.surah_id=%1.surah_id AND %1.text LIKE '%%2%'".arg(translation).arg(trimmedText)
	                    	sqlDataSource.load(0)
	                    }
	
						sqlDataSource.query = "select arabic.surah_id,arabic.verse_id,arabic.text,chapters.arabic_name as name, chapters.english_name, chapters.arabic_name, chapters.english_translation from arabic INNER JOIN chapters on chapters.surah_id=arabic.surah_id AND arabic.text LIKE '%%1%'".arg(trimmedText)
	                    sqlDataSource.load(1)
                    }
                }
            }

            attachedObjects: [
                CustomSqlDataSource {
                    property bool translationLoaded: false
                    property bool arabicLoaded: false
                    id: sqlDataSource
                    source: "app/native/assets/dbase/quran.db"
                    name: "search"

                    onDataLoaded: {
	                    theDataModel.insertList(data)
	                    
	                    if (id == 0) {
	                        translationLoaded = true
	                    } else if (id == 1) {
	                        arabicLoaded = true
	                    }
	                    
	                    if (translationLoaded && arabicLoaded) {
	                    	busy.running = false   
	                    }
                    }
                },
                
		        QTimer {
		            id: timer
		            singleShot: true
		            
		            onTimeout: {
		                searchField.requestFocus()
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
                    imageSource: "images/header_bg.png"
                },
                
		        ComponentDefinition {
		            id: definition
		            source: "SurahPage.qml"
		        }
            ]

            dataModel: GroupDataModel {
                id: theDataModel
                sortingKeys: ["name", "verse_id"]
                grouping: ItemGrouping.ByFullValue
            }
            
            onTriggered: {
                if (indexPath.length > 1)
                {
                    var data = dataModel.data(indexPath)
                    
		            var surahPage = definition.createObject()
		            surahPage.surahId = data.surah_id
		            surahPage.requestedVerse = data.verse_id
		            
		            properties.navPane.push(surahPage)
                }
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
                        id: itemRoot
                        leftPadding: 5; rightPadding: 5; bottomPadding: 5
                        horizontalAlignment: HorizontalAlignment.Fill
                        preferredWidth: 1280
                        
                        Divider {
                            visible: itemRoot.ListItem.indexPath[1] != 0
                            bottomMargin: 0
                        }
                        
                        Label {
                            text: ListItemData.text
                            multiline: true
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.color: Color.White
                            textStyle.textAlign: TextAlign.Center
                            topMargin: 0
                        }
                    }
                }
            ]
        }
    }
}