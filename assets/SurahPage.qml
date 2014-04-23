import bb.cascades 1.0
import bb.device 1.0
import bb.multimedia 1.0
import com.canadainc.data 1.0

Page
{
    id: surahPage
    property int surahId
    property int requestedVerse: -1
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll

    onSurahIdChanged:
    {
	    listView.chapterNumber = surahId;
        loadVerses();
    }
    
    function loadVerses()
    {
        helper.fetchAllAyats(surahPage, surahId);
        
        var translation = persist.getValueFor("translation");
        
        if (translation == "english") {
            helper.fetchTafsirForSurah(surahPage, surahId, false);
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
                listView.scrollToItem(target, ScrollAnimation.None);
                listView.select(target,true);
            } else if (surahId > 1 && surahId != 9) {
                listView.scrollToPosition(0, ScrollAnimation.None);
                listView.scroll(-100, ScrollAnimation.Smooth);
            }
        } else if (id == QueryId.FetchTafsirForSurah) {
            var verseModel = listView.dataModel;
            
            if ( !persist.contains("tafsirTutorialCount") ) {
                persist.showToast( qsTr("Press-and-hold on a verse with a grey highlight to find explanations on it."), qsTr("OK"), "asset:///images/ic_tafsir.png" );
                persist.saveValueFor("tafsirTutorialCount", 1);
            }
            
            for (var i = data.length-1; i >= 0; i--)
            {
                var target = [ data[i].verse_id-1, 0 ];
                var verseData = verseModel.data(target);
                verseData["hasTafsir"] = true;
                verseModel.updateItem(target, verseData);
            }
        }
    }

    onCreationCompleted: {
        persist.settingChanged.connect(reloadNeeded);
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: tafsirDelegate
            source: "TafseerPicker.qml"
        }
    ]

    actions: [
        ActionItem
        {
            id: scrollTop
            title: qsTr("Top") + Retranslate.onLanguageChanged
            imageSource: "file:///usr/share/icons/ic_go.png"

            onTriggered: {
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Default);
            }
            
            onCreationCompleted: {
                if (hw.isPhysicalKeyboardDevice) {
                    removeAction(scrollTop);
                }
            }
        },

        ActionItem
        {
            id: scrollBottom
            title: qsTr("Bottom") + Retranslate.onLanguageChanged
            imageSource: "images/ic_scroll_end.png"

            onTriggered: {
                listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Default);
            }
            
            onCreationCompleted: {
                if (hw.isPhysicalKeyboardDevice) {
                    removeAction(scrollBottom);
                }
            }
        },
        
        ActionItem
        {
            id: playAllAction
            title: player.playing ? qsTr("Pause") : qsTr("Play All")
            imageSource: player.playing ? "images/ic_pause.png" : "images/ic_play.png"
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

				if (player.active) {
				    player.togglePlayback();
				} else {
				    listView.previousPlayedIndex = -1;
                    recitation.downloadAndPlay( surahId, 1, listView.dataModel.size() );
				}
            }
        },

        ActionItem {
            id: tafsirAction
            
            title: qsTr("Tafsir") + Retranslate.onLanguageChanged
            imageSource: "images/ic_tafsir_show.png"

            onTriggered: {
                var page = tafsirDelegate.createObject();
                page.chapterNumber = surahId;
                page.verseNumber = 0;
                
                properties.navPane.push(page);
            }

            ActionBar.placement: ActionBarPlacement.OnBar
        }
    ]
    
    titleBar: ChapterTitleBar
    {
        id: ctb
        bgSource: "images/title_bg_alt.png"
        bottomPad: 0
        chapterNumber: surahId
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
            chapterName: qsTr("%1 (%2)").arg(ctb.titleText).arg(ctb.subtitleText)
            
            onTriggered: {
                var data = dataModel.data(indexPath);
                
                var created = tp.createObject();
                created.chapterNumber = surahId;
                created.verseNumber = data.verse_id;
                
                properties.navPane.push(created);
            }
        }
        
        gestureHandlers: [
            PinchHandler
            {
                onPinchEnded: {
                    var newValue = Math.floor(event.pinchRatio*listView.primarySize);
                    newValue = Math.max(8,newValue);
                    newValue = Math.min(newValue, 24);
                    
                    listView.primarySize = newValue;
                    persist.saveValueFor("primarySize", newValue);
                }
            }
        ]
        
        attachedObjects: [
            ComponentDefinition {
                id: tp
                source: "TafseerPicker.qml"
            },
            
            HardwareInfo {
                id: hw
            }
        ]
    }
}