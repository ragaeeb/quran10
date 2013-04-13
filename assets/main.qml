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
        
        contentContainer: Container {

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

					reload(data)

                    definition.source = "SurahPage.qml"
                    surahPage = definition.createObject()
                    surahPage.chapter = data
                    navigationPane.push(surahPage)
                }

                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill

                attachedObjects: [
                    CustomSqlDataSource {
                        id: sqlDataSource
                        source: "app/native/assets/dbase/quran.db"

                        onDataLoaded: {
                            if (!listView.surahPage) {
                                theDataModel.append(data)
                            } else {
                                listView.surahPage.load(data)
                            }
                        }
                    }
                ]
                
                function reload(data) {
                    var primary = app.getValueFor("primaryLanguage")
                    var translation = app.getValueFor("translation")

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
                    }
                }

                onCreationCompleted: {
                    sqlDataSource.query = "SELECT surah_id,arabic_name,english_name,english_translation FROM chapters"
                    sqlDataSource.load()
                    
                    app.settingChanged.connect(reloadNeeded)
                }
            }
        }
    }
}