import bb.cascades 1.0
import com.canadainc.data 1.0
import bb.system 1.0

ListView {
    property alias theDataModel: verseModel
    property alias listFade: fader
    property alias background: headerBackground
    property int chapterNumber
    property string chapterName
    property variant playlist
    property alias mediaPlayer: player
    property ActionSet sourceSet
    signal tafsirTriggered(int id);
    id: listView
    opacity: 0

    dataModel: GroupDataModel {
        id: verseModel
        sortingKeys: [ "verse_id" ]
        grouping: ItemGrouping.ByFullValue
    }
    
    leadingVisual: ControlDelegate
    {
        delegateActive: chapterNumber > 1
        horizontalAlignment: HorizontalAlignment.Fill

        sourceComponent: ComponentDefinition
        {
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                Label {
                    text: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"
                    horizontalAlignment: HorizontalAlignment.Fill
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSize: FontSize.XXLarge
                    textStyle.color: Color.Black
                    
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                }
            }
        }
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

    multiSelectAction: MultiSelectActionItem {}

    multiSelectHandler {
        actions: [
            ActionItem {
                id: multiCopyAction
                title: qsTr("Copy") + Retranslate.onLanguageChanged
                enabled: false
                imageSource: "images/ic_copy.png"
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
                imageSource: "images/ic_play.png"

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
    
    onCreationCompleted: {
        persist.settingChanged.connect(settingChanged);
    }

    function settingChanged(key) {
        if (key == "repeat") {
            player.setRepeat(persist.getValueFor("repeat") == 1 );
        } else if (key == "follow") {
            player.follow = persist.getValueFor("follow") == 1;
        }
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

    function bookmark(ListItemData)
    {
        var bookmarks = persist.getValueFor("bookmarks");

        if (! bookmarks) {
            bookmarks = [];
        }

        bookmarks.push({
                'surah_name': chapterName,
                'surah_id': chapterNumber,
                'verse_id': ListItemData.verse_id,
                'text': ListItemData.translation ? ListItemData.translation.substr(0,60)+"..." : ListItemData.arabic.substr(0,60)+"...",
                'type': "verse"
            });

        persist.saveValueFor("bookmarks", bookmarks);
        persist.showToast( qsTr("Bookmarked %1:%2").arg(chapterNumber).arg(ListItemData.verse_id) );
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

    function play(selectedVerses)
    {
        playlist = selectedVerses;
        var all = [];
        
        for (var i = 0; i < selectedVerses.length; i++) {
            all.push("file://" + app.generateFilePath(chapterNumber, selectedVerses[i]));
        }
        
        player.play(all);
    }
    
    function queryExplanationsFor(source, verseId)
    {
        sourceSet = source;
        
        sqlDataSource.query = "SELECT id,verse_id,description FROM tafsir_english WHERE surah_id=%1 AND verse_id=%2".arg(chapterNumber).arg(verseId);
        sqlDataSource.load(0);
    }

    attachedObjects: [
        ImagePaintDefinition {
            id: headerBackground
            imageSource: "images/header_bg.png"
        },

        DualChannelPlayer {
            id: player
            property bool follow: persist.getValueFor("follow") == 1
            repeat: persist.getValueFor("repeat") == 1

            onIndexChanged: {
                if (index >= 0)
                {
                    var actual = playlist[index] - 1;
                    var target = [ actual, 0 ];
                    var data = dataModel.data(target);
                    data["playing"] = true
                    verseModel.updateItem(target, data);

                    if (follow == 1) {
                        listView.scrollToItem(target, ScrollAnimation.Default);
                    }
                }
            }

            onPlaybackCompleted: {
                var actual = [ playlist[index]-1, 0 ];
                var data = verseModel.data(actual);
                data.playing = false;
                verseModel.updateItem(actual, data);
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
        },

        CustomSqlDataSource {
            id: sqlDataSource
            source: "app/native/assets/dbase/quran.db"
            name: "contextMenu"
            
            onDataLoaded: {
                if (id == 0 && sourceSet && data.length > 0) {
                    sourceSet.appendExplanations(data);
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
                
                onCreationCompleted: {
                    selectionChanged.connect(updateState);
                    playingChanged.connect(updateState);
                    activeChanged.connect(updateState);
                }
                
                onActiveChanged: {
                    if (active) {
                        itemRoot.ListItem.view.queryExplanationsFor(actionSet, ListItemData.verse_id);
                    }
                }
                
                onSelectionChanged: {
                    if (!selection)
                    {
                        for (var i = actionSet.count() - 1; i >= 0; i --) {
                            var current = actionSet.at(i);

                            if (current.id) {
                                actionSet.remove(current);
                                current.destroy();
                            }
                        }
                    }
                }

                contextActions: [
                    ActionSet {
                        id: actionSet
                        title: firstLabel.text
                        subtitle: labelDelegate.delegateActive ? labelDelegate.control.text : qsTr("%1:%2").arg(itemRoot.ListItem.view.chapterNumber).arg(ListItemData.verse_id)

                        ActionItem {
                            title: qsTr("Copy")
                            imageSource: "images/ic_copy.png"
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
                            title: qsTr("Bookmark") + Retranslate.onLanguageChanged
                            imageSource: "images/ic_bookmark.png"

                            onTriggered: {
                                itemRoot.ListItem.view.bookmark(ListItemData)
                            }
                        }

                        ActionItem {
                            id: audioAction

                            title: qsTr("Play")
                            imageSource: "images/ic_play.png"

                            onTriggered: {
                                if (! itemRoot.ListItem.view.fileExists(ListItemData)) {
                                    itemRoot.ListItem.view.download()
                                } else {
                                    itemRoot.ListItem.view.play([ ListItemData.verse_id ])
                                }
                            }
                        }
                        
                        function appendExplanations(data)
                        {
                            for (var i = data.length-1; i >= 0; i--)
                            {
                                if (data[i].verse_id == ListItemData.verse_id) {
                                    var action = actionDefinition.createObject();
                                    action.id = data[i].id;
                                    action.title = data[i].description;
                                    add(action);
                                }
                            }
                        }
                        
                        attachedObjects: [
                            ComponentDefinition {
                                id: actionDefinition
                                ActionItem {
                                    property int id
                                    imageSource: "images/ic_tafsir.png"
                                    
                                    onTriggered: {
                                        itemRoot.ListItem.view.tafsirTriggered(id);
                                    }
                                }
                            }
                        ]
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
                    textStyle.fontSize: FontSize.XXLarge
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