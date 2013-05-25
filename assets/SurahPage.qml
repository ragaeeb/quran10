import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    property variant surahId
    property int requestedVerse: -1
    property variant playlist
    property int currentTrack: 0

    onSurahIdChanged:
    {
        sqlDataSource.query = "SELECT english_name, english_translation, arabic_name FROM chapters WHERE surah_id=%1".arg(surahId);
        sqlDataSource.load(1);
        
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
			        }
                } else if (id == 1) {
			        surahNameArabic.text = data[0].arabic_name
			        surahNameEnglish.text = qsTr("%1 (%2)").arg(data[0].english_name).arg(data[0].english_translation)
                } else if (id == 5) {
                    tafsirDelegate.control.dm.clear();
                    tafsirDelegate.control.dm.append(data);

                    busy.running = false;
                    slider.visible = tafsirAction.tafsirShown;
                    slider.value = 0.5;
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
            title: qsTr("Play All") + Retranslate.onLanguageChanged
            imageSource: "images/ic_play.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered:
            {
                var downloaded = app.fileExists( surahId, listView.theDataModel.size() );
                
                if (!downloaded) {
                    listView.download();
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
            property bool tafsirShown: false
            
            title: tafsirShown ? qsTr("Hide Tafsir") : qsTr("Show Tafsir")
            imageSource: tafsirShown ? "images/ic_tafsir_hide.png" : "images/ic_tafsir_show.png"

            onTriggered: {
                tafsirShown = !tafsirShown;
                tafsirDelegate.delegateActive = tafsirShown;

                if (tafsirShown) {
                    busy.running = true;

                    var chapterId = surahId == 114 ? 113 : surahId;
                    sqlDataSource.query = "SELECT title,body FROM ibn_katheer_english WHERE surah_id=%1".arg(chapterId)
                    sqlDataSource.load(5)
                } else {
                    tafsirLayout.spaceQuota = -1;
                    slider.visible = false;
                }
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

            Slider {
                id: slider
                fromValue: 0
                toValue: 1
                visible: false
                horizontalAlignment: HorizontalAlignment.Center
                topMargin: 0

                animations: [
                    TranslateTransition {
                        id: translateSlider
                        fromX: 1000
                        duration: 500
                    }
                ]

                onVisibleChanged: {
                    if (visible && persist.getValueFor("animations") == 1) {
                        translateSlider.play();
                    }
                }

                onImmediateValueChanged: {
                    if (visible && immediateValue == 0) {
                        tafsirAction.triggered();
                    } else {
                        if (immediateValue == 0) {
                            tafsirLayout.spaceQuota = -1;
                        } else {
                            tafsirLayout.spaceQuota = immediateValue;
                        }
                    }
                }
            }
        }
        
        ActivityIndicator {
            id: busy
            running: true
            visible: running
            preferredHeight: 250
            horizontalAlignment: HorizontalAlignment.Center
        }
        
        Container
        {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            VersesListView {
                id: listView
                chapterNumber: surahId
            }
            
            ImageView {
                leftMargin: 0; rightMargin: 0;
                imageSource: "images/header_bg.png"
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Fill
            }
            
            ControlDelegate
            {
                id: tafsirDelegate
                delegateActive: slider.value > 0;
                
                sourceComponent: ComponentDefinition
                {
                    TafsirListView {
                        id: tafsirListView
                    }
                }

                layoutProperties: StackLayoutProperties {
                    id: tafsirLayout
                    spaceQuota: -1
                }
            }
        }
    }
}