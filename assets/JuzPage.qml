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
        if (ranges)
        {
            listView.chapterNumber = ranges.from_surah_id;
            ctb.chapterNumber = ranges.from_surah_id;
            helper.fetchAllAyats(juzPage, ranges.from_surah_id, ranges.to_surah_id);
        }
    }
    
    onPeekedAtChanged: {
        listView.secretPeek = peekedAt;
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchAllAyats)
        {
            data = offloader.removeOutOfRange(data, ranges.from_surah_id, ranges.from_verse_id, ranges.to_surah_id, ranges.to_verse_id);
            
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

    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(juzPage, listView);
        
        helper.textualChange.connect( function() {
            rangesChanged();
        });
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
            
            function performPlayback()
            {
                listView.previousPlayedIndex = -1;
                recitation.downloadAndPlayAll(listView.dataModel);
            }
            
            function onFinished(yesClicked)
            {
                if (yesClicked)
                {
                    persist.setFlag("hideDataWarning", 1);
                    performPlayback();
                }
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
                
                onBlockPeekChanged: {
                    navigationPane.peekEnabled = !blockPeek;
                }
                
                onTriggered: {
                    console.log("UserEvent: VerseTriggered");
                    
                    if (!scrolled)
                    {
                        var d = dataModel.data(indexPath);
                        
                        definition.source = "AyatPage.qml";
                        var ayatPage = definition.createObject();
                        ayatPage.surahId = d.surah_id;
                        ayatPage.verseId = d.verse_id;
                        
                        navigationPane.push(ayatPage);
                    }
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
        },
        
        ComponentDefinition {
            id: definition
        }
    ]
}