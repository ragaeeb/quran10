import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane {
    id: navigationPane
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        },
        
        ImagePaintDefinition {
            id: back
            imageSource: "images/background.png"
        }
    ]
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        id: mainPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        titleBar: QuranTitleBar {}
        
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
        
        Container
        {
            background: back.imagePaint
            
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
                    if ( text.match(/^\d{1,3}:\d{1,3}$/) || text.match(/^\d{1,3}$/) ) {
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
                        if ( text.match(/^\d{1,3}:\d{1,3}$/) || text.match(/^\d{1,3}$/) )
                        {
                            var tokens = text.split(":");
                            var surah = parseInt(tokens[0]);
                            
                            if (surah >= 1 && surah <= 114)
                            {
                                definition.source = "SurahPage.qml";
                                var surahPage = definition.createObject();
                                navigationPane.push(surahPage);
                                
                                surahPage.surahId = surah;
                                
                                if (tokens.length > 0) {
                                    var verse = parseInt(tokens[1]);
                                    surahPage.requestedVerse = verse;
                                }
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
                id: listView
                objectName: "listView"
                
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
                    var surahPage = definition.createObject();
                    surahPage.surahId = data.surah_id;
                    
                    navigationPane.push(surahPage);
                }
                
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllSurahs)
                    {
                        theDataModel.clear();
                        theDataModel.append(data);
                    }
                }
                
                onCreationCompleted: {
                    helper.dataLoaded.connect(onDataLoaded);
                    helper.fetchAllSurahs(listView, onDataLoaded);
                }
            }
        }
    }
}