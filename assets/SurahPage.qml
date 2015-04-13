import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: surahPage
    property int fromSurahId
    property int toSurahId
    property int requestedVerse
    property alias showContextMenu: listView.showContextMenu
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
    
    function reloadNeeded() {
        toSurahIdChanged();
    }
    
    onPeekedAtChanged: {
        listView.secretPeek = peekedAt;
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchAllAyats)
        {
            if ( listView.theDataModel.isEmpty() || listView.theDataModel.size() != data.length )
            {
                listView.theDataModel.clear();
                listView.theDataModel.append(data);
                
                if (requestedVerse > 0) {
                    var target = [requestedVerse-1]
                    listView.scrollToItem(target, ScrollAnimation.None);
                    listView.select(target,true);
                    requestedVerse = 0;
                } else if (fromSurahId > 1 && fromSurahId != 9) {
                    listView.scrollToPosition(0, ScrollAnimation.None);
                    listView.scroll(-100, ScrollAnimation.Smooth);
                }
            } else {
                for (var i = data.length-1; i >= 0; i--) {
                    listView.theDataModel.replace(i, data[i]);
                }
            }
            /*
            else if ( tutorialToast.tutorial( "tutorialCopyShare", qsTr("Press-and-hold any ayat and choose the Copy or Share action to easily share the verse."), "images/menu/ic_copy.png" ) ) {}
            else if ( tutorialToast.tutorial( "tutorialMemorize", qsTr("Press-and-hold any ayat and choose the Memorize action to play the next 8 verses in iteration to help you memorize them!"), "images/menu/ic_memorize.png" ) ) {}
            else if ( tutorialToast.tutorial( "tutorialRange", qsTr("Did you know you can press-and-hold on any verse and tap on the 'Select Range' action to only play recitations for those, or copy/share them to your contacts?"), "images/menu/ic_range.png" ) ) {}
            else if ( tutorialToast.tutorial( "donateNotice", qsTr("As'salaamu alaykum wa rahmatullahi wabarakathu,\n\nJazakAllahu khair for using Quran10. While our Islamic apps will always remain free of charge for your benefit, we encourage you to please donate whatever you can in order to support development. This will motivate the developers to continue to update the app, add new features and bug fixes. To donate, simply swipe-down from the top-bezel and tap the 'Donate' button to send money via PayPal.\n\nMay Allah reward you, and bless you and your family."), "images/ic_donate.png" ) ) {} */
            
            busy.delegateActive = false;
        }
    }
    
    function onPopped(page)
    {
        if (page == surahPage) {
            navigationPane.peekEnabled = true;
        }
    }

    onCreationCompleted: {
        helper.textualChange.connect(reloadNeeded);
        deviceUtils.attachTopBottomKeys(surahPage, listView);
        navigationPane.popTransitionEnded.connect(onPopped);
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
            
            function performPlayback()
            {
                listView.previousPlayedIndex = -1;
                recitation.downloadAndPlayAll(listView.dataModel);
            }
            
            function onFinished(yesClicked)
            {
                console.log("UserEvent: DownloadRecitationConfirm", yesClicked);
                
                if (yesClicked)
                {
                    persist.saveValueFor("hideDataWarning", 1, false);
                    performPlayback();
                }
            }
            
            function onReady(uri) {
                player.play(uri);
            }
            
            onCreationCompleted: {
                recitation.readyToPlay.connect(onReady);
            }
            
            onTriggered:
            {
                console.log("UserEvent: PlayAll");
                
                if (player.active) {
                    player.togglePlayback();
                } else if ( !persist.contains("hideDataWarning") && !player.active ) {
                    persist.showDialog( playAllAction, qsTr("Confirmation"), qsTr("We are about to download a whole bunch of MP3 recitations, you should only attempt to do this if you have either an unlimited data plan, or are connected via Wi-Fi. Otherwise you might incur a lot of data charges. Are you sure you want to continue? If you select No you can always attempt to download again later.") );
                } else {
                    performPlayback();
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
                    
                    requestedVerse = 0;
                    
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
                    
                    if (!scrolled) {
                        var d = dataModel.data(indexPath);
                        picked(d.surah_id, d.verse_id);
                    }
                }
                
                onBlockPeekChanged: {
                    navigationPane.peekEnabled = !blockPeek;
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