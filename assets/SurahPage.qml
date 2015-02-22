import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: surahPage
    property int fromSurahId
    property int toSurahId
    property int requestedVerse
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal picked(int surahId, int verseId)
    signal openChapterTafsir(int surahId)

    onToSurahIdChanged:
    {
        listView.chapterNumber = fromSurahId;
        ctb.chapterNumber = fromSurahId;
        busy.delegateActive = true;
        helper.fetchAllAyats(surahPage, fromSurahId, toSurahId);
    }
    
    function reloadNeeded(key)
    {
        if (key == "translation") {
            toSurahIdChanged();
        } else if (key == "primarySize" || key == "translationSize") {
            listView.refresh();
        }
    }
    
    onPeekedAtChanged: {
        listView.secretPeek = peekedAt;
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchAllAyats)
        {
            if ( listView.theDataModel.isEmpty() ) {
                listView.theDataModel.append(data);
            } else {
                for (var i = data.length-1; i >= 0; i--) {
                    listView.theDataModel.replace(i, data[i]);
                }
            }
            
            if (requestedVerse > 0) {
                var target = [requestedVerse-1]
                listView.scrollToItem(target, ScrollAnimation.None);
                listView.select(target,true);
                requestedVerse = 0;
            } else if (fromSurahId > 1 && fromSurahId != 9) {
                listView.scrollToPosition(0, ScrollAnimation.None);
                listView.scroll(-100, ScrollAnimation.Smooth);
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
            else if ( persist.tutorial( "donateNotice", qsTr("As'salaamu alaykum wa rahmatullahi wabarakathu,\n\nJazakAllahu khair for using Quran10. While our Islamic apps will always remain free of charge for your benefit, we encourage you to please donate whatever you can in order to support development. This will motivate the developers to continue to update the app, add new features and bug fixes. To donate, simply swipe-down from the top-bezel and tap the 'Donate' button to send money via PayPal.\n\nMay Allah reward you, and bless you and your family."), "asset:///images/ic_donate.png" ) ) {}
            
            busy.delegateActive = false;
        }
    }

    onCreationCompleted: {
        persist.settingChanged.connect(reloadNeeded);
        deviceUtils.attachTopBottomKeys(surahPage, listView);
    }

    actions: [
        ActionItem
        {
            id: playAllAction
            title: player.playing ? qsTr("Pause") : qsTr("Play All")
            imageSource: player.playing ? "images/menu/ic_pause.png" : "images/menu/ic_play.png"
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            shortcuts: [
                Shortcut {
                    key: qsTr("A") + Retranslate.onLanguageChanged
                }
            ]
            
            function onReady(uri) {
                player.play(uri);
            }
            
            onCreationCompleted: {
                recitation.readyToPlay.connect(onReady);
            }
            
            onTriggered:
            {
                console.log("UserEvent: PlayAll");
                
                if ( !persist.contains("hideDataWarning") && !player.active )
                {
                    var yesClicked = persist.showBlockingDialog( qsTr("Confirmation"), qsTr("We are about to download a whole bunch of MP3 recitations, you should only attempt to do this if you have either an unlimited data plan, or are connected via Wi-Fi. Otherwise you might incur a lot of data charges. Are you sure you want to continue? If you select No you can always attempt to download again later."), qsTr("Yes"), qsTr("No") );
                    
                    if (!yesClicked) {
                        return;
                    }

                    persist.saveValueFor("hideDataWarning", 1, false);
                }
                
				if (player.active) {
				    player.togglePlayback();
				} else {
				    listView.previousPlayedIndex = -1;
                    recitation.downloadAndPlayAll(listView.dataModel);
				}
            }
        },
        
        ActionItem
        {
            title: player.repeat ? qsTr("Disable Repeat") + Retranslate.onLanguageChanged : qsTr("Enable Repeat") + Retranslate.onLanguageChanged
            imageSource: player.repeat ? "images/menu/ic_repeat_on.png" : "images/menu/ic_repeat_off.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: RepeatAction");
                player.repeat = !player.repeat;
                persist.saveValueFor("repeat", player.repeat ? 1 : 0, false);
            }
        }
    ]
    
    titleBar: ChapterTitleBar
    {
        id: ctb
        bgSource: "images/title/title_bg_alt.png"
        bottomPad: 0
        
        onTitleTapped: {
            openChapterTafsir(chapterNumber);
        }
    }

    Container
    {
        layout: DockLayout {}
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        background: Color.White
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            ChapterNavigationBar
            {
                id: cnb
                chapterNumber: ctb.chapterNumber
                
                onNavigationTapped: {
                    if (right) {
                        ++fromSurahId;
                    } else {
                        --fromSurahId;
                    }
                    
                    if (toSurahId > 0) {
                        toSurahId = 0;
                    } else {
                        toSurahIdChanged();
                    }
                    
                    player.stop();
                }
            }
            
            VersesListView
            {
                id: listView
                
                onTriggered: {
                    console.log("UserEvent: VerseTriggered");
                    var d = dataModel.data(indexPath);

                    picked(d.surah_id, d.verse_id);
                }
                
                attachedObjects: [
                    ListScrollStateHandler {
                        id: scroller
                        
                        onFirstVisibleItemChanged: {
                            if (firstVisibleItem.length > 0)
                            {
                                var current = listView.theDataModel.data(firstVisibleItem);
                                
                                if (current.surah_id != ctb.chapterNumber) {
                                    ctb.chapterNumber = current.surah_id;
                                }
                            }
                        }
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
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_surah.png"
        }
    }
    
    attachedObjects: [
        LazyMediaPlayer
        {
            id: player
            repeat: persist.getValueFor("repeat") == 1
            
            onPlayingChanged: {
                if ( persist.getValueFor("keepAwakeDuringPlay") == 1 ) {
                    Application.mainWindow.screenIdleMode = player.playing ? 1 : 0;
                }
            }
        }
    ]
}