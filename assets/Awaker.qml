import bb.cascades 1.0
import com.canadainc.data 1.0

QtObject
{
    property variant parentPage
    property alias showContext: listView.showContextMenu
    signal versePicked(int surahId, int verseId)
    
    onParentPageChanged: {
        parentPage.addAction(playAllAction);
        parentPage.addAction(repeat);
        parentPage.addAction(follow);
        deviceUtils.attachTopBottomKeys(parentPage, awaker.lv);
    }
    
    property variant playAll: ActionItem
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
                persist.setFlag("hideDataWarning", 1);
                performPlayback();
            }
            
            analytics.record( "DownloadRecitationConfirm", yesClicked.toString() );
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
            } else if ( !persist.containsFlag("hideDataWarning") && !player.active ) {
                persist.showDialog( playAllAction, qsTr("Confirmation"), qsTr("We are about to download MP3 recitations, you should only attempt to do this if you have either a good data plan, or are connected via Wi-Fi. Otherwise you might incur a lot of data charges. Are you sure you want to continue? If you select No you can always attempt to download again later.") );
            } else {
                performPlayback();
            }
            
            var first = listView.dataModel.data([0]);
            var last = listView.dataModel.data( listView.dataModel.size()-1 );
            analytics.record("PlayAll", first.surah_id+":"+first.verse_id+"-"+last.surah_id+":"+last.verse_id);
        }
    }
    
    property variant repeatAction: ActionItem
    {
        id: repeat
        title: player.repeat ? qsTr("Disable Repeat") + Retranslate.onLanguageChanged : qsTr("Enable Repeat") + Retranslate.onLanguageChanged
        imageSource: player.repeat ? "images/menu/ic_repeat_on.png" : "images/menu/ic_repeat_off.png"
        ActionBar.placement: ActionBarPlacement.OnBar
        
        onTriggered: {
            console.log("UserEvent: RepeatAction");
            player.repeat = !player.repeat;
            persist.saveValueFor("repeat", player.repeat ? 1 : 0, false);
            
            analytics.record( "RepeatAction", player.repeat.toString() );
        }
    }
    
    property variant followAction: ActionItem
    {
        id: follow
        title: listView.follow ? qsTr("Follow On") + Retranslate.onLanguageChanged : qsTr("Follow Off") + Retranslate.onLanguageChanged
        imageSource: listView.follow ? "images/menu/ic_follow_on.png" : "images/menu/ic_follow_off.png"
        ActionBar.placement: ActionBarPlacement.OnBar
        
        onTriggered: {
            console.log("UserEvent: FollowTapped");
            persist.saveValueFor("follow", listView.follow ? 0 : 1);
            
            analytics.record( "FollowTapped", listView.follow.toString() );
        }
    }
    
    property variant lazyPlayer: LazyMediaPlayer
    {
        id: player
        repeat: persist.getValueFor("repeat") == 1
        
        onError: {
            console.log(message);
            persist.showToast( message, "asset:///images/toast/yellow_delete.png" );
        }
    }
    
    property variant lv: VersesListView
    {
        id: listView
        
        onTriggered: {
            console.log("UserEvent: VerseTriggered");
            
            if (!scrolled) {
                var d = dataModel.data(indexPath);
                versePicked(d.surah_id, d.verse_id);
                
                analytics.record( "VerseTriggered", d.surah_id+":"+d.verse_id );
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
    
    function onPopped(page)
    {
        if ( deviceUtils.isEqual(page, parentPage) )
        {
            navigationPane.peekEnabled = true;
            Application.mainWindow.screenIdleMode = 0;
        }
    }
    
    function onPushed(page)
    {
        if ( !deviceUtils.isEqual(navigationPane.top, parentPage) )
        {
            navigationPane.peekEnabled = true;
            Application.mainWindow.screenIdleMode = 0;
        }
    }
    
    function onSettingChanged(key)
    {
        if (key == "keepAwakeDuringPlay")
        {
            var keepAwake = persist.getValueFor("keepAwakeDuringPlay") == 1;
            Application.mainWindow.screenIdleMode = player.playing && keepAwake && Application.isFullscreen() && Application.isAwake() ? 1 : 0;
        }
    }
    
    function refresh() {
        onSettingChanged("keepAwakeDuringPlay");
    }
    
    onCreationCompleted: {
        navigationPane.pushTransitionEnded.connect(onPushed);
        navigationPane.popTransitionEnded.connect(onPopped);
        persist.settingChanged.connect(onSettingChanged);
        player.playingChanged.connect(refresh);
        Application.invisible.connect(refresh);
        Application.thumbnail.connect(refresh);
        Application.fullscreen.connect(refresh);
        Application.awake.connect(refresh);
    }
}