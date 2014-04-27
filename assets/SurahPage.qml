import bb.cascades 1.0
import bb.device 1.0
import bb.multimedia 1.0
import com.canadainc.data 1.0

Page
{
    id: surahPage
    property int surahId
    property int requestedVerse: 0
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
            requestedVerse = scroller.firstVisibleItem[0];
            loadVerses();
        }
    }
    
    onPeekedAtChanged: {
        listView.secretPeek = peekedAt;
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchAllAyats) {
            listView.theDataModel.clear();
            listView.theDataModel.insertList(data);
            busy.running = false
            
            if (requestedVerse > 0) {
                var target = [ requestedVerse - 1, 0 ]
                listView.scrollToItem(target, ScrollAnimation.None);
                listView.select(target,true);
                requestedVerse = -1;
            } else if (surahId > 1 && surahId != 9) {
                listView.scrollToPosition(0, ScrollAnimation.None);
                listView.scroll(-100, ScrollAnimation.Smooth);
            }
        } else if (id == QueryId.FetchTafsirForSurah) {
            var verseModel = listView.dataModel;
            
            for (var i = data.length-1; i >= 0; i--)
            {
                var target = [ data[i].verse_id-1, 0 ];
                var verseData = verseModel.data(target);
                verseData["hasTafsir"] = true;
                verseModel.updateItem(target, verseData);
            }
            
            if ( persist.tutorial( "tutorialZoom", qsTr("You can do a pinch gesture anytime to increase and decrease the font size of the Arabic/Transliteration text!"), "asset:///images/ic_quran.png" ) ) { }
            else if ( persist.tutorial( "tafsirTutorialCount", qsTr("Tap on a verse with a grey highlight to find explanations on it."), "asset:///images/toast/ic_tafsir.png" ) ) { }
            else if ( persist.tutorial( "tutorialSurahNavigation", qsTr("Tap the left/right arrow keys to navigate to the previous and next chapters respectively."), "asset:///images/title/ic_next.png" ) ) {}
            else if ( persist.tutorial( "tutorialFollow", qsTr("Use the follow button at the center of the left/right buttons if you want to follow the verses automatically as they are being recited."), "asset:///images/title/ic_follow_on.png" ) ) {}
            else if ( persist.tutorial( "tutorialRepeat", qsTr("Tap on the repeat action at the bottom to enable or disable repeating the recitation in a loop once it finishes."), "asset:///images/menu/ic_repeat_on.png" ) ) {}
            else if ( persist.tutorial( "tutorialCopyShare", qsTr("Press-and-hold any ayat and choose the Copy or Share action to easily share the verse."), "asset:///images/ic_copy.png" ) ) {}
            else if ( persist.tutorial( "tutorialMemorize", qsTr("Press-and-hold any ayat and choose the Memorize action to play the next 8 verses in iteration to help you memorize them!"), "asset:///images/menu/ic_memorize.png" ) ) {}
            else if ( persist.tutorial( "tutorialRange", qsTr("Did you know you can press-and-hold on any verse and tap on the 'Select Range' action to only play recitations for those, or copy/share them to your contacts?"), "asset:///images/menu/ic_range.png" ) ) {}
            else if ( persist.tutorial( "tutorialHome", qsTr("Want to dock a certain ayat right to your home screen? Press-and-hold on it and choose 'Add To Home Screen' and name it!"), "asset:///images/menu/ic_home.png" ) ) {}
            else if ( persist.tutorial( "tutorialBookmark", qsTr("Do you know how to set bookmarks? You can easily mark certain ayats as favourites by pressing-and-holding on them and choosing 'Add Bookmark' on them! This is a very easy way to track our progress as you read the Qu'ran to quickly find where you left off."), "asset:///images/menu/ic_bookmark_add.png" ) ) {}
        }
    }
    
    function onPopEnded(page)
    {
        if (navigationPane.top == surahPage) {
            ctb.navigationExpanded = true;
        }
    }

    onCreationCompleted: {
        persist.settingChanged.connect(reloadNeeded);
        navigationPane.popTransitionEnded.connect(onPopEnded);
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
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.None);
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
            imageSource: "images/menu/ic_scroll_end.png"

            onTriggered: {
                listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.None);
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
            imageSource: player.playing ? "images/menu/ic_pause.png" : "images/menu/ic_play.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            shortcuts: [
                Shortcut {
                    key: qsTr("A") + Retranslate.onLanguageChanged
                }
            ]
            
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
        
        ActionItem
        {
            title: recitation.repeat ? qsTr("Disable Repeat") + Retranslate.onLanguageChanged : qsTr("Enable Repeat") + Retranslate.onLanguageChanged
            imageSource: recitation.repeat ? "images/menu/ic_repeat_off.png" : "images/menu/ic_repeat_on.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                persist.saveValueFor("repeat", recitation.repeat ? 0 : 1);
            }
        },

        ActionItem {
            id: tafsirAction
            title: qsTr("Tafsir") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_tafsir_show.png"

            onTriggered: {
                ctb.navigationExpanded = false;
                var page = tafsirDelegate.createObject();

                navigationPane.push(page);
                
                page.chapterNumber = surahId;
                page.verseNumber = 0;
            }
            
            shortcuts: [
                Shortcut {
                    key: qsTr("K") + Retranslate.onLanguageChanged
                }
            ]

            ActionBar.placement: ActionBarPlacement.OnBar
        }
    ]
    
    titleBar: ChapterTitleBar
    {
        id: ctb
        bgSource: "images/title/title_bg_alt.png"
        bottomPad: 0
        chapterNumber: surahId
        showNavigation: true
        navigationExpanded: true
        
        onNavigationTapped: {
            if (right) {
                ++surahId;
            } else {
                --surahId;
            }
        }
    }

    Container
    {
        layout: DockLayout {}
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
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
            
            VersesListView
            {
                id: listView
                chapterName: qsTr("%1 (%2)").arg(ctb.titleText).arg(ctb.subtitleText)
                
                onTriggered: {
                    ctb.navigationExpanded = false;
                    var data = dataModel.data(indexPath);
                    
                    var created = tp.createObject();
                    created.chapterNumber = surahId;
                    created.verseNumber = data.verse_id;
                    
                    navigationPane.push(created);
                }
                
                attachedObjects: [
                    ListScrollStateHandler {
                        id: scroller
                    }
                ]
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
        
        DownloadsOverlay
        {
            downloadText: qsTr("%1").arg(recitation.queued) + Retranslate.onLanguageChanged
            delegateActive: recitation.queued > 0
            
            onCancelClicked: {
                recitation.abort();
            }
        }
    }
}