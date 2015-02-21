import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: juzPage
    property int juzId
    property variant ranges
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll

    onJuzIdChanged:
    {
        busy.delegateActive = true;
        helper.fetchJuzInfo(juzPage, juzId);
    }
    
    onRangesChanged: {
        listView.chapterNumber = ranges.from_surah_id;
        ctb.chapterNumber = ranges.from_surah_id;
        helper.fetchAllAyats(juzPage, ranges.from_surah_id, ranges.to_surah_id);
    }
    
    function reloadNeeded(key)
    {
        if (key == "translation") {
            requestedVerse = scroller.firstVisibleItem[0];
            juzIdChanged();
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
            data = helper.removeOutOfRange(data, ranges.from_surah_id, ranges.from_verse_id, ranges.to_surah_id, ranges.to_verse_id);
            
            listView.theDataModel.clear();
            listView.theDataModel.append(data);
            busy.delegateActive = false;
        } else if (id == QueryId.FetchJuz) {
            var toChapter = 114;
            var toVerse = 300;
            
            if (data.length > 1) {
                toChapter = data[1].surah_id;
                toVerse = data[1].verse_number;
            }
            
            ranges = {'from_surah_id': data[0].surah_id, 'from_verse_id': data[0].verse_id, 'to_surah_id': toChapter, 'to_verse_id': toVerse};
        }
    }
    
    function onPopEnded(page)
    {
        if (navigationPane.top == juzPage) {
            ctb.navigationExpanded = true;
        }
    }

    onCreationCompleted: {
        persist.settingChanged.connect(reloadNeeded);
        navigationPane.popTransitionEnded.connect(onPopEnded);
        
        deviceUtils.attachTopBottomKeys(juzPage, listView);
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
        scrollBehavior: TitleBarScrollBehavior.Sticky
        
        onTitleTapped: {
            definition.source = "ChapterTafsirPicker.qml";
            var p = definition.createObject();
            p.chapterNumber = chapterNumber;
            
            navigationPane.push(p);
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
                        ++juzId;
                    } else {
                        --juzId;
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
                    
                    definition.source = "AyatPage.qml";
                    var ayatPage = definition.createObject();
                    ayatPage.surahId = d.surah_id;
                    ayatPage.verseId = d.verse_id;
                    
                    navigationPane.push(ayatPage);
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
        },
        
        ComponentDefinition {
            id: definition
        }
    ]
}