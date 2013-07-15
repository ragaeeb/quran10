import bb.cascades 1.0
import com.canadainc.data 1.0

Tab
{
    NavigationPane {
        id: navigationPane

        attachedObjects: [
            ComponentDefinition {
                id: definition
            }
        ]

        onPopTransitionEnded: {
            page.destroy();
        }

        BasePage
        {
            id: mainPage
            
            actions: [
                ActionItem {
                    title: qsTr("Mushaf") + Retranslate.onLanguageChanged
                    imageSource: "images/ic_mushaf.png"
                    ActionBar.placement: ActionBarPlacement.OnBar
                    
                    onTriggered: {
                        definition.source = "MushafSheet.qml";
                        var sheet = definition.createObject();
                        
                        sheet.open();
                    }
                }
            ]

            contentContainer: Container
            {
                TextField
                {
                    hintText: qsTr("Search surah name...") + Retranslate.onLanguageChanged
                    bottomMargin: 0
                    horizontalAlignment: HorizontalAlignment.Fill

                    onCreationCompleted: {
                        inputRoute.primaryKeyTarget = true;
                        translate.play();
                    }

                    onTextChanging: {
                        if ( text.match(/^\d{1,3}:\d{1,3}$/) ) {
                            var tokens = text.split(":");
                            var surah = parseInt(tokens[0]);
                            sqlDataSource.query = "SELECT surah_id,arabic_name,english_name,english_translation FROM chapters WHERE surah_id=%1".arg(surah);
                            sqlDataSource.load();
                        } else if (text.length > 2) {
                            sqlDataSource.query = "SELECT surah_id,arabic_name,english_name,english_translation FROM chapters WHERE english_name like '%%1%' OR arabic_name like '%%1%'".arg(text);
                            sqlDataSource.load();
                        } else if (text.length == 0) {
                            sqlDataSource.query = "SELECT surah_id,arabic_name,english_name,english_translation FROM chapters";
                            sqlDataSource.load();
                        }
                    }
                    
                    input {
                        submitKey: SubmitKey.Submit
                        
                        onSubmitted: {
                            if ( text.match(/^\d{1,3}:\d{1,3}$/) )
                            {
                                var tokens = text.split(":");
                                var surah = parseInt(tokens[0]);
                                var verse = parseInt(tokens[1]);
                                
                                if (surah >= 1 && surah <= 114)
                                {
                                    definition.source = "SurahPage.qml";
                                    var surahPage = definition.createObject();
                                    navigationPane.push(surahPage);
                                    
                                    surahPage.surahId = surah;
                                    surahPage.requestedVerse = verse;
                                }
                            }
                        }
                    }

                    animations: [
                        TranslateTransition {
                            id: translate
                            fromX: 1000
                            duration: 500
                        }
                    ]
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
                                imageSource: "images/ic_quran.png"
                            }
                        }
                    ]

                    onTriggered: {
                        var data = listView.dataModel.data(indexPath);

                        definition.source = "SurahPage.qml";
                        surahPage = definition.createObject();
                        surahPage.surahId = data.surah_id;

                        navigationPane.push(surahPage);
                    }

                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill

                    attachedObjects: [
                        CustomSqlDataSource {
                            id: sqlDataSource
                            source: "app/native/assets/dbase/quran.db"
                            name: "main"

                            onDataLoaded: {
                                if (! listView.surahPage) {
                                    theDataModel.clear()
                                    theDataModel.append(data)
                                } else {
                                    listView.surahPage.load(data)
                                }
                            }
                        }
                    ]

                    onCreationCompleted: {
                        sqlDataSource.query = "SELECT surah_id,arabic_name,english_name,english_translation FROM chapters"
                        sqlDataSource.load();
                    }
                }
            }
        }
    }
}