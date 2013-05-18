import bb.cascades 1.0
import bb.multimedia 1.0
import com.canadainc.data 1.0
import bb.system 1.0

Page
{
    property variant surahId
    property int requestedVerse: -1
    property variant playlist
    property int currentTrack: 0

    onSurahIdChanged:
    {
        sqlDataSource.query = "SELECT english_name, english_translation, arabic_name FROM chapters WHERE surah_id=%1".arg(surahId)
        sqlDataSource.load(1)
        
        loadVerses()
    }
    
    function loadVerses()
    {
        var primary = persist.getValueFor("primary")
        var translation = persist.getValueFor("translation")

        if (translation != "") {
            sqlDataSource.query = "SELECT %1.text as arabic,%1.verse_id,%2.text as translation FROM %1 INNER JOIN %2 on %1.surah_id=%2.surah_id AND %1.verse_id=%2.verse_id AND %1.surah_id=%3".arg(primary).arg(translation).arg(surahId)
        } else {
        	sqlDataSource.query = "SELECT text as arabic,verse_id FROM %1 WHERE surah_id=%2".arg(primary).arg(surahId)
        }

        sqlDataSource.load(0)
    }
    
    function reloadNeeded(key)
    {
        if (key == "translation" || key == "primary") {
            loadVerses()
        }
    }
    
    onCreationCompleted: {
        persist.settingChanged.connect(reloadNeeded);
        queue.queueCompleted.connect(playAllAction.triggered);
        
        if ( persist.getValueFor("tipFontSize") != 1 ) {
            persist.showToast( qsTr("Tip: If the font size is too small to read, you can always increase the size by going to your BB10 device settings -> Display -> and increasing the font size from there!"), qsTr("OK") );
            persist.saveValueFor("tipFontSize", 1);
        }
    }
    
    attachedObjects: [
        CustomSqlDataSource {
            id: sqlDataSource
            source: "app/native/assets/dbase/quran.db"
            name: "surah"

            onDataLoaded: {
                if (id == 0) {
			        theDataModel.clear()
			        theDataModel.insertList(data)
			        busy.running = false
			        listFade.play()
			        
			        if (requestedVerse > 0) {
			            var target = [ requestedVerse - 1, 0 ]
			            listView.scrollToItem(target, ScrollAnimation.Default);
			            listView.select(target,true);
			        }
                } else if (id == 1) {
			        surahNameArabic.text = data[0].arabic_name
			        surahNameEnglish.text = qsTr("%1 (%2)").arg(data[0].english_name).arg(data[0].english_translation)
                } else if (id == 5) {
                    list2Del.control.dm.clear();
                    list2Del.control.dm.append(data);

                    busy.running = false;
                    slider.visible = tafsirAction.tafsirShown;
                    slider.value = 0.5;
                }
            }
        }
    ]

    actions: [
        ActionItem {
            title: qsTr("Top") + Retranslate.onLanguageChanged
            imageSource: "file:///usr/share/icons/ic_go.png"

            onTriggered: {
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Default)
            }
        },

        ActionItem {
            title: qsTr("Bottom") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ic_scroll_end.png"

            onTriggered: {
                listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Default)
            }
        },
        
        ActionItem {
            id: playAllAction
            title: qsTr("Play All") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ic_play.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered:
            {
                var downloaded = app.fileExists( surahId, theDataModel.size() )
                
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
        },

        ActionItem {
            id: tafsirAction
            property bool tafsirShown: false
            
            title: tafsirShown ? qsTr("Hide Tafsir") : qsTr("Show Tafsir")
            imageSource: tafsirShown ? "asset:///images/ic_tafsir_hide.png" : "asset:///images/ic_tafsir_show.png"

            onTriggered: {
                tafsirShown = !tafsirShown;
                list2Del.delegateActive = tafsirShown;

                if (tafsirShown) {
                    busy.running = true;

                    var chapterId = surahId == 114 ? 113 : surahId;
                    sqlDataSource.query = "SELECT title,body FROM ibn_katheer_english WHERE surah_id=%1".arg(chapterId)
                    sqlDataSource.load(5)
                } else {
                    tafsirLayout.spaceQuota = -1;
                    slider.visible = false;
                }
            }

            ActionBar.placement: ActionBarPlacement.OnBar
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
        
        Slider {
            id: slider
            fromValue: 0
            toValue: 1
            visible: false
            horizontalAlignment: HorizontalAlignment.Center
            topMargin: 0; bottomMargin: 0

            animations: [
                TranslateTransition {
                    id: translateSlider
                    fromX: 1000
                    duration: 500
                }
            ]

            onVisibleChanged: {
                if ( visible && persist.getValueFor("animations") == 1 ) {
                    translateSlider.play();
                }
            }
            
            onImmediateValueChanged: {
                if (visible && immediateValue == 0) {
                    tafsirAction.triggered();
                } else {
                    tafsirLayout.spaceQuota = immediateValue;
                }
            }
        }
        
        ActivityIndicator {
            id: busy
            running: true
            visible: running
            preferredHeight: 250
            horizontalAlignment: HorizontalAlignment.Center
        }
        
        Container
        {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }

            ListView {
                property alias background: bg
                property variant chapterNumber: surahId
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
                    for (var i = selectedIndices.length - 1; i >= 0; i --) {
                        if (selectedIndices[i].length > 1) {
                            n ++
                        }
                    }

                    multiSelectHandler.status = qsTr("%1 ayahs selected").arg(n) + Retranslate.onLanguageChanged
                    multiShareAction.enabled = multiPlayAction.enabled = multiCopyAction.enabled = n > 0
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
                        app.downloadChapter(chapterNumber, theDataModel.size())
                    }
                }

                function fileExists(ListItemData) {
                    return app.fileExists(chapterNumber, ListItemData.verse_id)
                }

                function playFile(verseId) {
                    player.stop()
                    player.sourceUrl = "file://" + app.generateFilePath(chapterNumber, verseId)

                    if (nowPlaying.acquired) {
                        player.play();
                    } else {
                        nowPlaying.acquire()
                    }

                    var index = playlist[currentTrack] - 1;
                    var target = [index,0];
                    var data = theDataModel.data(target);
                    data["playing"] = true
                    theDataModel.updateItem(target, data);

					if ( persist.getValueFor("follow") == 1 ) {
                        listView.scrollToItem(target, ScrollAnimation.Default);
                    }
                }

                function play(selectedVerses) {
                    playlist = selectedVerses

                    if (currentTrack != 0) {
                        currentTrack = 0;
                        player.reset()
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
                            var index = playlist[currentTrack] - 1;
                            var data = theDataModel.data([ index, 0 ]);
                            data.playing = false;
                            theDataModel.updateItem([ index, 0 ], data);

                            player.positionChanged(0);
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
                                app.downloadChapter(surahId, theDataModel.size())
                            }
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
            
            ImageView {
                leftMargin: 0; rightMargin: 0;
                imageSource: "asset:///images/header_bg.png"
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Fill
            }
            
            ControlDelegate
            {
                id: list2Del
                delegateActive: slider.value > 0;
                
                sourceComponent: ComponentDefinition
                {
                    ListView
                    {
                        property variant background: bg2
                        property alias dm: arrayDataModel
                        
                        attachedObjects: [
                            ImagePaintDefinition {
                                id: bg2
                                imageSource: "asset:///images/header_bg.png"
                            }
                        ]
                        
                        dataModel: ArrayDataModel {
                            id: arrayDataModel
                        }

                        function copyItem(ListItemData) {
                            persist.copyToClipboard( qsTr("%1\n\n%2").arg(ListItemData.title).arg(ListItemData.body) );
                        }

                        function shareItem(ListItemData) {
                            var result = qsTr("%1\n\n%2").arg(ListItemData.title).arg(ListItemData.body);
                            result = persist.convertToUtf8(result)
                            return result;
                        }

                        listItemComponents: [
                            ListItemComponent {
								Container
								{
								    id: tafsirItemRoot

                                    property bool active: ListItem.active
                                    property bool selected: ListItem.selected

                                    horizontalAlignment: HorizontalAlignment.Fill
                                    verticalAlignment: VerticalAlignment.Fill
                                    background: active || selected ? Color.DarkGreen : undefined
                                    
                                    Container {
                                        background: tafsirItemRoot.ListItem.view.background.imagePaint
                                        horizontalAlignment: HorizontalAlignment.Fill
                                        topPadding: 5
                                        bottomPadding: 5
                                        leftPadding: 5

                                        layout: StackLayout {
                                            orientation: LayoutOrientation.LeftToRight
                                        }

                                        Label {
                                            id: headerLabel
                                            text: ListItemData.title
                                            horizontalAlignment: HorizontalAlignment.Fill
                                            textStyle.fontSize: FontSize.XXSmall
                                            textStyle.color: Color.White
                                            textStyle.fontWeight: FontWeight.Bold
                                            textStyle.textAlign: TextAlign.Center
                                            multiline: true

                                            layoutProperties: StackLayoutProperties {
                                                spaceQuota: 1
                                            }
                                        }
                                    }

                                    Container {
                                        topPadding: 5
                                        bottomPadding: 5
                                        leftPadding: 5
                                        rightPadding: 5
                                        horizontalAlignment: HorizontalAlignment.Fill
                                        preferredWidth: 1280

                                        Label {
                                            id: bodyLabel
                                            text: ListItemData.body
                                            multiline: true
                                            horizontalAlignment: HorizontalAlignment.Fill
                                            textStyle.color: active || selected ? Color.White : Color.Black
                                            textStyle.textAlign: TextAlign.Center
                                        }
                                    }

                                    contextActions: [
                                        ActionSet {
                                            title: headerLabel.text
                                            subtitle: bodyLabel.text

                                            ActionItem {
                                                title: qsTr("Copy") + Retranslate.onLanguageChanged
                                                imageSource: "asset:///images/ic_copy.png"
                                                onTriggered: {
                                                    tafsirItemRoot.ListItem.view.copyItem(ListItemData)
                                                }
                                            }

                                            InvokeActionItem {
                                                title: qsTr("Share") + Retranslate.onLanguageChanged

                                                query {
                                                    mimeType: "text/plain"
                                                    invokeActionId: "bb.action.SHARE"
                                                }

                                                onTriggered: {
                                                    data = tafsirItemRoot.ListItem.view.shareItem(ListItemData)
                                                }
                                            }

                                            ActionItem {
                                                title: qsTr("Top") + Retranslate.onLanguageChanged
                                                imageSource: "file:///usr/share/icons/ic_go.png"

                                                onTriggered: {
                                                    tafsirItemRoot.ListItem.view.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Default)
                                                }
                                            }

	                                        ActionItem {
	                                            title: qsTr("Bottom") + Retranslate.onLanguageChanged
	                                            imageSource: "asset:///images/ic_scroll_end.png"
	
	                                            onTriggered: {
                                                    tafsirItemRoot.ListItem.view.scrollToPosition(ScrollPosition.End, ScrollAnimation.Default)
	                                            }
	                                        }
	                                    }
                                    ]
                                }
                            }
                        ]
                    }
                }

                layoutProperties: StackLayoutProperties {
                    id: tafsirLayout
                    spaceQuota: -1
                }
            }
        }
    }
}