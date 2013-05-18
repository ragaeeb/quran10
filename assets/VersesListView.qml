import bb.cascades 1.0
import com.canadainc.data 1.0
import bb.system 1.0

ListView {
    property alias theDataModel: verseModel
    property alias listFade: fader
    property alias background: bg
    property variant chapterNumber
    id: listView
    opacity: 0

    dataModel: GroupDataModel {
        id: verseModel
        sortingKeys: [ "verse_id" ]
        grouping: ItemGrouping.ByFullValue
    }

    onSelectionChanged: {
        var n = 0
        var selectedIndices = listView.selectionList()
        for (var i = selectedIndices.length - 1; i >= 0; i --) {
            if (selectedIndices[i].length > 1) {
                n ++;
            }
        }

        multiSelectHandler.status = qsTr("%1 ayahs selected").arg(n) + Retranslate.onLanguageChanged;
        multiShareAction.enabled = multiPlayAction.enabled = multiCopyAction.enabled = n > 0;
    }

    function getSelectedTextualData() {
        var selectedIndices = selectionList()
        var result = ""
        var first
        var last

        for (var i = 0; i < selectedIndices.length; i ++) {
            if (selectedIndices[i].length > 1) {
                var current = dataModel.data(selectedIndices[i])

                result += renderItem(current)

                if (i < selectedIndices.length - 1) {
                    result += "\n"
                }

                if (! first) {
                    first = current.verse_id
                }

                last = current.verse_id
            }
        }

        if (first && last) {
            result += qsTr("%1:%2-%3").arg(chapterNumber).arg(first).arg(last)
            return result;
        } else {
            return ""
        }
    }

    multiSelectAction: MultiSelectActionItem {
    }

    multiSelectHandler {
        actions: [
            ActionItem {
                id: multiCopyAction
                title: qsTr("Copy") + Retranslate.onLanguageChanged
                enabled: false
                imageSource: "asset:///images/ic_copy.png"
                onTriggered: {
                    var result = listView.getSelectedTextualData()
                    persist.copyToClipboard(result)
                }
            },

            InvokeActionItem {
                id: multiShareAction
                title: qsTr("Share") + Retranslate.onLanguageChanged

                query {
                    mimeType: "text/plain"
                    invokeActionId: "bb.action.SHARE"
                }

                onTriggered: {
                    var result = listView.getSelectedTextualData()
                    result = persist.convertToUtf8(result)
                    multiShareAction.data = result
                }
            },

            ActionItem {
                id: multiPlayAction

                title: qsTr("Play") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/ic_play.png"

                onTriggered: {
                    var selectedIndices = listView.selectionList()
                    var last = listView.dataModel.data(selectedIndices[selectedIndices.length - 1])
                    var downloaded = listView.fileExists(last)

                    if (! downloaded) {
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

    function renderItem(ListItemData) {
        var result = ListItemData.arabic + "\n"

        if (ListItemData.translation && ListItemData.translation.length > 0) {
            result += ListItemData.translation + "\n"
        }

        return result
    }

    function getTextualData(ListItemData) {
        var result = renderItem(ListItemData)
        result += qsTr("%1:%2").arg(chapterNumber).arg(ListItemData.verse_id)
        return result;
    }

    function copyItem(ListItemData) {
        var result = getTextualData(ListItemData)
        persist.copyToClipboard(result)
    }

    function shareItem(ListItemData) {
        var result = getTextualData(ListItemData)
        result = persist.convertToUtf8(result)
        return result;
    }

    function bookmark(ListItemData) {
        persist.saveValueFor("bookmark", {
                'surah': chapterNumber,
                'verse': ListItemData.verse_id
            })
        persist.showToast(qsTr("Bookmarked %1:%2").arg(chapterNumber).arg(ListItemData.verse_id))
    }

    function download() {
        if (persist.getValueFor("hideDataWarning") == 0) {
            prompt.show()
        } else {
            app.downloadChapter(chapterNumber, verseModel.size())
        }
    }

    function fileExists(ListItemData) {
        return app.fileExists(chapterNumber, ListItemData.verse_id)
    }

    function playFile(verseId)
    {
        player.play( "file://" + app.generateFilePath(chapterNumber, verseId) );

        var index = playlist[currentTrack] - 1;
        var target = [ index, 0 ];
        var data = dataModel.data(target);
        data["playing"] = true
        verseModel.updateItem(target, data);

        if (persist.getValueFor("follow") == 1) {
            listView.scrollToItem(target, ScrollAnimation.Default);
        }
    }

    function play(selectedVerses) {
        playlist = selectedVerses

        if (currentTrack != 0) {
            currentTrack = 0;
        }

        skip(currentTrack)
    }

    function skip(n) {
        var desired = currentTrack + n;

        if (desired >= 0 && desired < playlist.length) {
            currentTrack = desired
            playFile(playlist[currentTrack])
        } else if (persist.getValueFor("repeat") == 1) {
            currentTrack = 0
            playFile(playlist[currentTrack])
        }
    }

    attachedObjects: [
        ImagePaintDefinition {
            id: bg
            imageSource: "asset:///images/header_bg.png"
        },

        LazyMediaPlayer {
            id: player

            onPlaybackCompleted: {
                var index = playlist[currentTrack] - 1;
                var data = verseModel.data([ index, 0 ]);
                data.playing = false;
                verseModel.updateItem([ index, 0 ], data);

                listView.skip(1);
            }
        },

        SystemDialog {
            id: prompt
            title: qsTr("Confirmation") + Retranslate.onLanguageChanged
            body: qsTr("We are about to download a whole bunch of MP3 recitations, you should only attempt to do this if you have either an unlimited data plan, or are connected via Wi-Fi. Otherwise you might incur a lot of data charges. Are you sure you want to continue? If you select No you can always attempt to download again later.") + Retranslate.onLanguageChanged
            confirmButton.label: qsTr("Yes") + Retranslate.onLanguageChanged
            cancelButton.label: qsTr("No") + Retranslate.onLanguageChanged

            onFinished: {
                if (result == SystemUiResult.ConfirmButtonSelection) {
                    app.downloadChapter(surahId, verseModel.size())
                }
            }
        }
    ]

    animations: FadeTransition {
        id: fader
        toOpacity: 1
    }

    listItemComponents: [

        ListItemComponent {
            type: "header"

            Container {
                id: headerRoot
                background: ListItem.view.background.imagePaint
                horizontalAlignment: HorizontalAlignment.Fill
                topPadding: 5
                bottomPadding: 5
                leftPadding: 5

                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }

                Label {
                    text: qsTr("%1:%2").arg(headerRoot.ListItem.view.chapterNumber).arg(ListItemData)
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

            Container {
                property bool selection: ListItem.selected
                property bool active: ListItem.active
                property bool playing: ListItemData.playing ? ListItemData.playing : false

                background: playing ? Color.create("#ffff8c00") : undefined

                id: itemRoot

                function updateState() {
                    if (playing) {
                        background = Color.create("#ffff8c00")
                    } else if (selection || active) {
                        background = Color.DarkGreen
                    } else {
                        background = undefined
                    }
                }

                onPlayingChanged: {
                    updateState()
                }

                onSelectionChanged: {
                    updateState()
                }

                onActiveChanged: {
                    updateState()
                }

                contextActions: [
                    ActionSet {
                        title: firstLabel.text
                        subtitle: labelDelegate.delegateActive ? labelDelegate.control.text : qsTr("%1:%2").arg(itemRoot.ListItem.view.chapterNumber).arg(ListItemData.verse_id)

                        ActionItem {
                            title: qsTr("Copy")
                            imageSource: "asset:///images/ic_copy.png"
                            onTriggered: {
                                itemRoot.ListItem.view.copyItem(ListItemData)
                            }
                        }

                        InvokeActionItem {
                            id: iai
                            title: qsTr("Share")

                            query {
                                mimeType: "text/plain"
                                invokeActionId: "bb.action.SHARE"
                            }

                            onTriggered: {
                                iai.data = itemRoot.ListItem.view.shareItem(ListItemData)
                            }
                        }

                        ActionItem {
                            title: qsTr("Set Bookmark") + Retranslate.onLanguageChanged
                            imageSource: "asset:///images/ic_bookmark.png"

                            onTriggered: {
                                itemRoot.ListItem.view.bookmark(ListItemData)
                            }
                        }

                        ActionItem {
                            id: audioAction

                            title: qsTr("Play")
                            imageSource: "asset:///images/ic_play.png"

                            onTriggered: {
                                if (! itemRoot.ListItem.view.fileExists(ListItemData)) {
                                    itemRoot.ListItem.view.download()
                                } else {
                                    itemRoot.ListItem.view.play([ ListItemData.verse_id ])
                                }
                            }
                        }
                    }
                ]

                topPadding: 5
                bottomPadding: 5
                leftPadding: 5
                rightPadding: 5
                horizontalAlignment: HorizontalAlignment.Fill
                preferredWidth: 1280

                Label {
                    id: firstLabel
                    text: ListItemData.arabic
                    multiline: true
                    horizontalAlignment: HorizontalAlignment.Fill
                    textStyle.color: selection || active || playing ? Color.White : Color.Black
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSize: FontSize.Large
                }

                ControlDelegate {
                    id: labelDelegate
                    sourceComponent: labelDefinition
                    delegateActive: ListItemData.translation && ListItemData.translation.length > 0 ? true : false
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

    layoutProperties: StackLayoutProperties {
        spaceQuota: 0.5
    }

    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
}