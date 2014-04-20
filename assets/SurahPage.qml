import bb.cascades 1.2
import com.canadainc.data 1.0
import bb.multimedia 1.0

Page
{
    id: surahPage
    property int surahId
    property int requestedVerse: -1
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll

    onSurahIdChanged:
    {
	    listView.chapterNumber = surahId;
        helper.fetchSurahHeader(surahPage, surahId);

        loadVerses();
    }
    
    function loadVerses()
    {
        helper.fetchAllAyats(surahPage, surahId);
        
        var translation = persist.getValueFor("translation");
        
        if (translation == "english") {
            helper.fetchTafsirForSurah(surahPage, surahId);
            surahPage.addAction(tafsirAction);   
        } else {
            surahPage.removeAction(tafsirAction);
        }
    }
    
    function reloadNeeded(key)
    {
        if (key == "translation" || key == "primary" || key == "primarySize" || key == "translationSize") {
            loadVerses()
        }
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
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchAllAyats) {
            listView.theDataModel.clear();
            listView.theDataModel.insertList(data);
            busy.running = false
            listView.listFade.play();
            
            if (requestedVerse > 0) {
                var target = [ requestedVerse - 1, 0 ]
                listView.scrollToItem(target, ScrollAnimation.Default);
                listView.select(target,true);
            } else if (surahId > 1 && surahId != 9) {
                listView.scrollToPosition(0, ScrollAnimation.None);
                listView.scroll(-100, ScrollAnimation.Smooth);
            }
        } else if (id == QueryId.FetchSurahHeader) {
            surahNameArabic.text = data[0].arabic_name
            surahNameEnglish.text = qsTr("%1 (%2)").arg(data[0].english_name).arg(data[0].english_translation)
        } else if (id == QueryId.FetchTafsirForSurah) {
            var verseModel = listView.dataModel;
            
            if ( persist.getValueFor("tafsirTutorialCount") != 1 ) {
                persist.showToast( qsTr("Press-and-hold on a verse with a grey highlight to find explanations on it."), qsTr("OK") );
                persist.saveValueFor("tafsirTutorialCount", 1);
            }
            
            for (var i = data.length-1; i >= 0; i--)
            {
                var verse = data[i].verse_id;
                
                if (verse) {
                    var target = [ verse-1, 0 ];
                    var verseData = verseModel.data(target);
                    verseData["hasTafsir"] = true;
                    verseModel.updateItem(target, verseData);
                } else {
                    var ai = actionDefinition.createObject();
                    ai.title = data[i].description;
                    ai.id = data[i].id;
                    surahPage.addAction(ai, ActionBarPlacement.Default);   
                }
            }
        }
    }

    onCreationCompleted: {
        persist.settingChanged.connect(reloadNeeded);
        helper.dataLoaded.connect(onDataLoaded);
    }
    
    attachedObjects: [
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
            title: recitation.player.playing ? qsTr("Pause") : qsTr("Play All")
            imageSource: recitation.player.playing ? "images/ic_pause.png" : "images/ic_play.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered:
            {
                if ( !persist.contains("hideDataWarning") )
                {
                    var yesClicked = persist.showBlockingDialog( qsTr("Confirmation"), qsTr("We are about to download a whole bunch of MP3 recitations, you should only attempt to do this if you have either an unlimited data plan, or are connected via Wi-Fi. Otherwise you might incur a lot of data charges. Are you sure you want to continue? If you select No you can always attempt to download again later."), qsTr("Yes"), qsTr("No") );
                    
                    if (!yesClicked) {
                        return;
                    }

                    persist.saveValueFor("hideDataWarning", 1);
                }

				if (recitation.player.active) {
				    recitation.player.togglePlayback();
				} else {
				    listView.fromVerse = 1;
                    recitation.downloadAndPlay( surahId, 1, listView.dataModel.size() );
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
                page.surahId = surahId;
                
                properties.navPane.push(page);
            }

            ActionBar.placement: ActionBarPlacement.OnBar
        }
    ]
    
    titleBar: TitleBar
    {
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties
        {
            content: Container
            {
                topPadding: 10;
                
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
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
        }
    }

    Container
    {
        background: Color.White
        
        ActivityIndicator {
            id: busy
            running: true
            visible: running
            preferredHeight: 250
            horizontalAlignment: HorizontalAlignment.Center
        }

        VersesListView {
            id: listView
            chapterName: qsTr("%1 (%2)").arg(surahNameArabic.text).arg(surahNameEnglish.text)
            
            onCreationCompleted: {
                tafsirTriggered.connect(showExplanation);
            }
        }
    }
}