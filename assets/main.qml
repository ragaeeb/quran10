import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane

    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]

    onPopTransitionEnded: {
        page.destroy();
    }

    Menu.definition: MenuDefinition
    {
        id: menu
        
        settingsAction: SettingsActionItem
        {
            property Page settingsPage

            onTriggered: {
                if (! settingsPage) {
                    definition.source = "SettingsPage.qml"
                    settingsPage = definition.createObject()
                }

                navigationPane.push(settingsPage);
            }
        }

        helpAction: HelpActionItem {
            property Page helpPage

            onTriggered: {
                if (! helpPage) {
                    definition.source = "HelpPage.qml"
                    helpPage = definition.createObject();
                }

                navigationPane.push(helpPage);
            }
        }
    }

    BasePage
    {
        id: mainPage
        
        function updateBookmark()
        {
            var bookmark = persist.getValueFor("bookmark")

            if (bookmark) {
                bookmarkAction.title = qsTr("%1:%2").arg(bookmark.surah).arg(bookmark.verse) + Retranslate.onLanguageChanged
                bookmarkAction.enabled = true
            }
        }

        onCreationCompleted: {
            updateBookmark()
        }
        
        actions: [
            ActionItem {
                title: qsTr("Search") + Retranslate.onLanguageChanged
                imageSource: "file:///usr/share/icons/bb_action_searchtwitter.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    definition.source = "SearchPage.qml"
                    var searchPage = definition.createObject()
                    navigationPane.push(searchPage)
                }
            },
            
            ActionItem {
                id: bookmarkAction
                title: qsTr("No bookmark") + Retranslate.onLanguageChanged
                imageSource: "file:///usr/share/icons/bb_action_flag.png"
                enabled: false
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    var bookmark = persist.getValueFor("bookmark")

                    listView.process(bookmark.surah)
                    listView.surahPage.requestedVerse = bookmark.verse
                }
            },
            
	        InvokeActionItem {
	            query {
	                mimeType: "text/html"
	                uri: "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=dar.as.sahaba@hotmail.com&currency_code=CAD&no_shipping=1&tax=0&lc=CA&bn=PP-DonationsBF&item_name=Da'wah Activities, Rent and Utility Expenses for the Musalla (please do not use credit cards)"
	                invokeActionId: "bb.action.OPEN"
	            }
	            
	            title: qsTr("Donate") + Retranslate.onLanguageChanged
	            imageSource: "file:///usr/share/icons/ic_accept.png"
	            ActionBar.placement: ActionBarPlacement.OnBar
	        }
        ]
        
        contentContainer: Container {

			TextField {
                hintText: qsTr("Search surah name...") + Retranslate.onLanguageChanged
                bottomMargin: 0;
                
                onTextChanging: {
                    if (text.length > 2) {
	                    sqlDataSource.query = "SELECT surah_id,arabic_name,english_name,english_translation FROM chapters WHERE english_name like '%"+text+"%' OR arabic_name like '%"+text+"%'"
	                    sqlDataSource.load()
                    } else if (text.length == 0) {
	                    sqlDataSource.query = "SELECT surah_id,arabic_name,english_name,english_translation FROM chapters"
	                    sqlDataSource.load()
                    }
                }
            }

            ListView {
            	property variant surahPage
                id: listView

                dataModel: ArrayDataModel {
                    id: theDataModel
                }

                listItemComponents: [
                    ListItemComponent {
                        StandardListItem {
                            title: ListItemData.english_name
                            description: ListItemData.arabic_name
                            status: ListItemData.surah_id
                            imageSource: "asset:///images/ic_quran.png"
                        }
                    }
                ]

                onTriggered: {
                    var data = listView.dataModel.data(indexPath)
                    process(data.surah_id)
                }

                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill

                attachedObjects: [
                    CustomSqlDataSource {
                        id: sqlDataSource
                        source: "app/native/assets/dbase/quran.db"
                        name: "main"

                        onDataLoaded: {
                            if (!listView.surahPage) {
                                theDataModel.clear()
                                theDataModel.append(data)
                            } else {
                                listView.surahPage.load(data)
                            }
                        }
                    }
                ]
                
                function process(data)
                {
                    definition.source = "SurahPage.qml"
                    surahPage = definition.createObject()
                    surahPage.surahId = data

                    navigationPane.push(surahPage)
                }
                
                function reloadNeeded(key)
                {
                    if (key == "bookmark") {
                        mainPage.updateBookmark()
                    }
                }

                onCreationCompleted: {
                    sqlDataSource.query = "SELECT surah_id,arabic_name,english_name,english_translation FROM chapters"
                    sqlDataSource.load()
                    
                    persist.settingChanged.connect(reloadNeeded)
                }
            }
        }
    }
}