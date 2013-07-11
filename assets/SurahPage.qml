import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: surahPage
    property variant surahId
    property int requestedVerse: -1
    property int currentTrack: 0

    onSurahIdChanged:
    {
        sqlDataSource.query = "SELECT english_name, english_translation, arabic_name FROM chapters WHERE surah_id=%1".arg(surahId);
        sqlDataSource.load(1);

        sqlDataSource.query = "SELECT id,description FROM tafsir_english WHERE surah_id=%1 AND verse_id IS NULL".arg(surahId);
        sqlDataSource.load(80);

        loadVerses();
    }
    
    function loadVerses()
    {
        var primary = persist.getValueFor("primary")
        var translation = persist.getValueFor("translation")

        if (translation != "") {
            sqlDataSource.query = "SELECT %1.text as arabic,%1.verse_id,%2.text as translation FROM %1 INNER JOIN %2 on %1.surah_id=%2.surah_id AND %1.verse_id=%2.verse_id AND %1.surah_id=%3".arg(primary).arg(translation).arg(surahId);
        } else {
        	sqlDataSource.query = "SELECT text as arabic,verse_id FROM %1 WHERE surah_id=%2".arg(primary).arg(surahId);
        }

        sqlDataSource.load(0)
    }
    
    function reloadNeeded(key)
    {
        if (key == "translation" || key == "primary") {
            loadVerses()
        }
    }
    
    function startPlayback() {
        playAllAction.triggered();
    }
    
    function showExplanation(id)
    {
        tafsirDelegate.source = "TafseerPage.qml";
        var tafsirPage = tafsirDelegate.createObject();
        tafsirPage.tafsirId = id;

        paneProperties.navPane.push(tafsirPage);
    }

    paneProperties: NavigationPaneProperties {
        property variant navPane: navigationPane
        id: properties
    }

    onCreationCompleted: {
        persist.settingChanged.connect(reloadNeeded);
        queue.queueCompleted.connect(startPlayback);
    }
    
    attachedObjects: [
        CustomSqlDataSource {
            id: sqlDataSource
            source: "app/native/assets/dbase/quran.db"
            name: "surah"

            onDataLoaded: {
                if (id == 0) {
			        listView.theDataModel.clear();
			        listView.theDataModel.insertList(data);
			        busy.running = false
			        listView.listFade.play();
			        
			        if (requestedVerse > 0) {
			            var target = [ requestedVerse - 1, 0 ]
			            listView.scrollToItem(target, ScrollAnimation.Default);
			            listView.select(target,true);
			        } else {
                        listView.scrollToPosition(0, ScrollAnimation.None);
                        listView.scroll(-100, ScrollAnimation.Smooth);
                    }
                } else if (id == 1) {
			        surahNameArabic.text = data[0].arabic_name
			        surahNameEnglish.text = qsTr("%1 (%2)").arg(data[0].english_name).arg(data[0].english_translation)
                } else if (id == 80) {
                    for (var i = data.length-1; i >= 0; i--) {
                        var ai = actionDefinition.createObject();
                        ai.title = data[i].description;
                        ai.id = data[i].id;
                        surahPage.addAction(ai,ActionBarPlacement.Default);
                    }
                }
            }
        },
        
        ComponentDefinition {
            id: tafsirDelegate
        },
        
        ComponentDefinition
        {
            id: actionDefinition
            
            ActionItem {
                property int id
                imageSource: "images/ic_tafsir.png"
                
                onTriggered: {
                    showExplanation(id);
                }
            }
        }
    ]

    actions: [
        ActionItem {
            title: qsTr("Top") + Retranslate.onLanguageChanged
            imageSource: "file:///usr/share/icons/ic_go.png"

            onTriggered: {
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Default);
            }
        },

        ActionItem {
            title: qsTr("Bottom") + Retranslate.onLanguageChanged
            imageSource: "images/ic_scroll_end.png"

            onTriggered: {
                listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Default);
            }
        },
        
        ActionItem {
            id: playAllAction
            title: listView.mediaPlayer.playing ? qsTr("Pause") : qsTr("Play All")
            imageSource: listView.mediaPlayer.playing ? "images/ic_pause.png" : "images/ic_play.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered:
            {
                var downloaded = app.fileExists( surahId, listView.theDataModel.size() );
                
                if (!downloaded) {
                    listView.download();
                } else if (listView.mediaPlayer.playing) {
                    listView.mediaPlayer.pause();
                } else if (listView.playlist) {
                    listView.mediaPlayer.resume();
                } else {
	                var result = []
	                
	                var n = listView.theDataModel.size();

                    for (var i = 1; i <= n; i ++) {
					    result.push(i);
					}
					
					listView.play(result);
                }
            }
        },

        ActionItem {
            id: tafsirAction
            
            title: qsTr("Ibn Katheer") + Retranslate.onLanguageChanged
            imageSource: "images/ic_tafsir_show.png"

            onTriggered: {
                tafsirDelegate.source = "TafseerIbnKatheer.qml";
                var page = tafsirDelegate.createObject();
                page.load(surahNameEnglish.text, surahNameArabic.text, surahId);
                
                properties.navPane.push(page);
            }

            ActionBar.placement: ActionBarPlacement.OnBar
        }
    ]

    Container
    {
        background: Color.White
        
        Container {
            id: titleBar
            
            topPadding: 10; bottomPadding: 25

            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Top
            background: back.imagePaint
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: back
                    imageSource: "images/title_bg_alt.png"
                }
            ]
            
            Label {
                id: surahNameArabic
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.XXSmall
                textStyle.fontWeight: FontWeight.Bold
                bottomMargin: 5
            }

            Label {
                id: surahNameEnglish
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.XXSmall
                textStyle.fontWeight: FontWeight.Bold
                topMargin: 0
            }
        }
        
        ActivityIndicator {
            id: busy
            running: true
            visible: running
            preferredHeight: 250
            horizontalAlignment: HorizontalAlignment.Center
        }

        VersesListView {
            id: listView
            chapterNumber: surahId
            chapterName: qsTr("%1 (%2)").arg(surahNameArabic.text).arg(surahNameEnglish.text)
            
            onCreationCompleted: {
                tafsirTriggered.connect(showExplanation);
            }
        }
    }
}