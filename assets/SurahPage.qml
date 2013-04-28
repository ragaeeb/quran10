import bb.cascades 1.0
import bb.multimedia 1.0

Page
{
    property alias chapter: listView.chapterNumber
    property int requestedIndex: -1
    property variant playlist
    property int currentTrack: 0

    onChapterChanged: {
        surahNameArabic.text = chapter.arabic_name
        surahNameEnglish.text = qsTr("%1 (%2)").arg(chapter.english_name).arg(chapter.english_translation)
    }
    
    function load(values) {
        theDataModel.clear()
        theDataModel.insertList(values)
        busy.running = false
        listFade.play()
        
        if (requestedIndex > 0) {
            var target = [ requestedIndex - 1, 0 ]
            listView.scrollToItem(target, ScrollAnimation.Default)
            listView.select(target,true)
        }
    }

    actions: [
        ActionItem {
            title: qsTr("Top") + Retranslate.onLanguageChanged
            imageSource: "file:///usr/share/icons/ic_go.png"

            onTriggered: {
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Default)
            }

            ActionBar.placement: ActionBarPlacement.OnBar
        },

        ActionItem {
            title: qsTr("Bottom") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ic_scroll_end.png"

            onTriggered: {
                listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Default)
            }

            ActionBar.placement: ActionBarPlacement.OnBar
        },
        
        ActionItem {
            title: qsTr("Play All") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ic_play.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered:
            {
                var downloaded = app.fileExists( chapter.surah_id, theDataModel.size() )
                
                if (!downloaded) {
                    listView.download()
                } else {
	                var result = []
	                
					for (var i = 1; i <= theDataModel.size(); i ++) {
					    result.push(i)
					}
					
					listView.play(result)                    
                }
            }
        }
    ]

    Container
    {
        background: Color.White
        
        Container {
            id: titleBar
            
            topPadding: 10; bottomPadding: 20

            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Top
            background: back.imagePaint
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: back
                    imageSource: "asset:///images/title_bg_alt.png"
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

        ListView {
        	property alias background: bg
        	property variant chapterNumber
            id: listView
            opacity: 0

            dataModel: GroupDataModel {
                id: theDataModel
                sortingKeys: [ "verse_id" ]
                grouping: ItemGrouping.ByFullValue
            }

            onSelectionChanged: {
                var n = 0
                var selectedIndices = listView.selectionList()
				for (var i = selectedIndices.length-1; i >= 0; i--)
				{
				    if (selectedIndices[i].length > 1) {
				        n++
				    }
				}
                
                multiSelectHandler.status = qsTr("%1 ayahs selected").arg(n) + Retranslate.onLanguageChanged
                multiPlayAction.enabled = multiCopyAction.enabled = n > 0
            }
            
            multiSelectAction: MultiSelectActionItem {}

            multiSelectHandler {
                actions: [
                    ActionItem {
                        id: multiCopyAction
                        title: qsTr("Copy")
                        enabled: false
                        imageSource: "asset:///images/ic_copy.png"
                        onTriggered: {
                            var selectedIndices = listView.selectionList()
                            var result = ""
                            var first
                            var last

							for (var i = 0; i < selectedIndices.length; i ++)
							{
							    if (selectedIndices[i].length > 1)
							    {
							        var current = listView.dataModel.data(selectedIndices[i])
							        
							     	result += listView.renderItem(current)
								    
								    if (i < selectedIndices.length-1) {
								        result += "\n"
								    }
								    
								    if (!first) {
								        first = current.verse_id
								    }
								    
								    last = current.verse_id
							    }
							}

							if (first && last) {
	                            result += qsTr("%1:%2-%3").arg(listView.chapterNumber.surah_id).arg(first).arg(last)
	                            persist.copyToClipboard(result)
							}
                        }
                    },
                    
                    ActionItem {
                        id: multiPlayAction
                        
                        title: qsTr("Play")
                        imageSource: "asset:///images/ic_play.png"

                        onTriggered: {
                            var selectedIndices = listView.selectionList()
                            var last = listView.dataModel.data(selectedIndices[selectedIndices.length-1])
                            var downloaded = listView.fileExists(last)
                            
                            if (!downloaded) {
                                listView.download()
                            } else {
                                var result = []
                                
								for (var i = 0; i < selectedIndices.length; i ++) {
								    var current = listView.dataModel.data(selectedIndices[i]).verse_id
								    result.push(current)
								}
								
								listView.play(result)
                            }
                        }
                    }
                ]

                status: qsTr("None selected") + Retranslate.onLanguageChanged
            }
            
            function renderPrimary(ListItemData) {
                return ListItemData.english_transliteration ? ListItemData.english_transliteration.replace(/<(?:.|\n)*?>/gm, '') : ListItemData.arabic
            }
            
            function renderItem(ListItemData) {
                var result = renderPrimary(ListItemData) + "\n"

                if (ListItemData.translation && ListItemData.translation.length > 0) {
                    result += ListItemData.translation + "\n"
                }

                return result
            }
            
            function copyItem(ListItemData) {
                var result = renderItem(ListItemData)
                result += qsTr("%1:%2").arg(chapterNumber.surah_id).arg(ListItemData.verse_id)
                persist.copyToClipboard(result)
            }
            
            function bookmark(ListItemData) {
                persist.saveValueFor("bookmark", {'surah': chapterNumber.surah_id, 'verse': ListItemData.verse_id})
                persist.showToast( qsTr("Bookmarked %1:%2").arg(chapterNumber.surah_id).arg(ListItemData.verse_id) )
            }
            
            function download() {
                app.downloadChapter( chapterNumber.surah_id, theDataModel.size() )
            }
            
            function fileExists(ListItemData) {
                return app.fileExists( chapterNumber.surah_id, ListItemData.verse_id )
            }
            
            function playFile(verseId)
            {
				player.stop()
				player.sourceUrl = "file://"+app.generateFilePath(chapterNumber.surah_id, verseId)

				if (nowPlaying.acquired) {
		            player.play();
		        } else {
		            nowPlaying.acquire()
		        }
				
                var index = playlist[currentTrack]-1
                var data = theDataModel.data([index,0])
                data["playing"] = true
                theDataModel.updateItem([index,0],data)
            }
            
            function play(selectedVerses) {
                playlist = selectedVerses
                
                if (currentTrack != 0) {
	                currentTrack = 0;
	                player.reset()                    
                }

                skip(currentTrack)
            }
            
		    function skip(n)
		    {
		        var desired = currentTrack+n;
		        
				if (desired >= 0 && desired < playlist.length) {
				    currentTrack = desired
				    playFile(playlist[currentTrack])
				} else if ( persist.getValueFor("repeat") == 1 ) {
				    currentTrack = 0
				    playFile(playlist[currentTrack])
				}
		    }

            attachedObjects: [
                ImagePaintDefinition {
                    id: bg
                    imageSource: "asset:///images/header_bg.png"
                },
                
		        NowPlayingConnection {
		            id: nowPlaying
		            connectionName: "quran10"
		            
		            onAcquired: {
		                player.reset()
		                player.play()
		            }
		            
		            onPause: {
		                player.pause()
		            }
		            
		            onRevoked: {
		                player.stop()
		            }
		        },
		        
		        MediaPlayer {
		            id: player
		            
		            onPlaybackCompleted: {
		                var index = playlist[currentTrack]-1
		                var data = theDataModel.data([index,0])
		                data.playing = false
		                theDataModel.updateItem([index,0],data)
		                
		                player.positionChanged(0)
		                listView.skip(1)
		            }
		        }
            ]
            
            animations: FadeTransition {
                id: listFade
                toOpacity: 1
            }

            listItemComponents: [
                
                ListItemComponent {
                    type: "header"

                    Container {
                        id: headerRoot
                        background: ListItem.view.background.imagePaint
                        horizontalAlignment: HorizontalAlignment.Fill
                        topPadding: 5; bottomPadding: 5; leftPadding: 5
                        
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }

                        Label {
                            text: qsTr("%1:%2").arg(headerRoot.ListItem.view.chapterNumber.surah_id).arg(ListItemData)
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.fontSize: FontSize.XXSmall
                            textStyle.color: Color.White
                            textStyle.fontWeight: FontWeight.Bold
                            textStyle.textAlign: TextAlign.Center
                            
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                        }
                    }
                },

                ListItemComponent {
                    type: "item"
                    
                    Container
                    {
                        property bool selection: ListItem.selected
                        property bool active: ListItem.active
                        property bool playing: ListItemData.playing ? ListItemData.playing : false
                        
                        background: playing ? Color.create("#ffff8c00") : undefined

                        id: itemRoot
                        
                        onPlayingChanged: {
                            background = playing && !selection && !active ? Color.create("#ffff8c00") : undefined
                        }
                        
                        onSelectionChanged: {
                            if (selection) {
                                background = Color.DarkGreen
                            } else if (playing) {
                                background = Color.create("#ffff8c00")
                            } else {
                                background = undefined
                            }
                        }
                        
                        onActiveChanged: {
                            if (selection || active) {
                                background = Color.DarkGreen
                            } else if (playing) {
                                background = Color.create("#ffff8c00")
                            } else {
                                background = undefined
                            }
                        }

                        contextActions: [
                            ActionSet {
                                title: firstLabel.text
                                subtitle: labelDelegate.delegateActive ? labelDelegate.control.text : qsTr("%1:%2").arg(itemRoot.ListItem.view.chapterNumber.surah_id).arg(ListItemData.verse_id)
                                
                                ActionItem {
                                    title: qsTr("Copy")
                                    imageSource: "asset:///images/ic_copy.png"
                                    onTriggered: {
                                        itemRoot.ListItem.view.copyItem(ListItemData)
                                    }
                                }
                                
                                ActionItem {
                                    title: qsTr("Set Bookmark") + Retranslate.onLanguageChanged
                                    imageSource: "file:///usr/share/icons/bb_action_flag.png"
                                    
                                    onTriggered: {
                                        itemRoot.ListItem.view.bookmark(ListItemData)
                                    }
                                }
                                
                                ActionItem {
                                    id: audioAction
                                    
                                    title: qsTr("Play") 
                                    imageSource: "asset:///images/ic_play.png"

                                    onTriggered: {
                                        if ( !itemRoot.ListItem.view.fileExists(ListItemData) ) {
                                        	itemRoot.ListItem.view.download()
                                        } else {
                                            itemRoot.ListItem.view.play([ListItemData.verse_id])
                                        }
                                    }
                                }
                            }
                        ]

                        topPadding: 5; bottomPadding: 5; leftPadding: 5; rightPadding: 5
                        horizontalAlignment: HorizontalAlignment.Fill
                        preferredWidth: 1280

                        Label {
                            id: firstLabel
                            text: itemRoot.ListItem.view.renderPrimary(ListItemData)
                            multiline: true
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.color: selection || active || playing ? Color.White : Color.Black
                            textStyle.textAlign: TextAlign.Center
                        }
                        
                        ControlDelegate {
                            id: labelDelegate
                            sourceComponent: labelDefinition
                            delegateActive: ListItemData.translation && ListItemData.translation.length > 0
                            horizontalAlignment: HorizontalAlignment.Fill
                        }

                        attachedObjects: [
                            ComponentDefinition {
                                id: labelDefinition

                                Label {
                                    id: translationLabel
                                    text: ListItemData.translation
                                    multiline: true
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    textStyle.color: selection || active || playing ? Color.White : Color.Black
                                    textStyle.textAlign: TextAlign.Center
                                    visible: text.length > 0
                                }
                            }
                        ]
                    }
                }
            ]

            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
        }
    }
}