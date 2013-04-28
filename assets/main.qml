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
                    var data = theDataModel.value(bookmark.surah - 1) // surahs start at 1

                    listView.process(data)
                    listView.surahPage.requestedIndex = bookmark.verse
                }
            }
        ]
        
        contentContainer: Container {

            ListView {
            	property variant surahPage
                id: listView

                dataModel: ArrayDataModel {
                    id: theDataModel
                }
                
                leadingVisualSnapThreshold: 1
                
                leadingVisual: TextField {
                    hintText: qsTr("Search surah name...") + Retranslate.onLanguageChanged
                    
                    onTextChanging: {
                        if (text.length > 2) {
		                    sqlDataSource.query = "SELECT surah_id,arabic_name,english_name,english_translation FROM chapters WHERE english_name like '%"+text+"%'"
		                    sqlDataSource.load()
                        } else if (text.length == 0) {
		                    sqlDataSource.query = "SELECT surah_id,arabic_name,english_name,english_translation FROM chapters"
		                    sqlDataSource.load()
                        }
                    }
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
                    process(data)
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
                    surahPage.chapter = data

                    reload(data)

                    navigationPane.push(surahPage)
                }
                
                function reload(data) {
                    var primary = persist.getValueFor("primaryLanguage")
                    var translation = persist.getValueFor("translation")

                    if (translation != "") {
                        translation = "," + translation + " as translation"
                    }

                    sqlDataSource.query = "SELECT " + primary + ",verse_id" + translation + " FROM quran WHERE surah_id=" + data.surah_id
                    sqlDataSource.load()
                }
                
                function reloadNeeded(key)
                {
                    if ( listView.surahPage && (key == "primaryLanguage" || key == "translation") ) {
                        reload(listView.surahPage.chapter)
                    } else if (key == "bookmark") {
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