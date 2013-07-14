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
        delegateActive: chapterNumber > 1 && chapterNumber != 9
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

    multiSelectHandler {
        actions: [
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

    function renderItem(ListItemData)
    {
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
        app.bookmarkVerse(chapterName, chapterNumber, ListItemData);
        persist.showToast( qsTr("Bookmarked %1:%2").arg(chapterNumber).arg(ListItemData.verse_id) );
    }

    function download() {
        if (persist.getValueFor("hideDataWarning") == 0) {
            prompt.show()
        } else {
            app.downloadChapter(chapterNumber, verseModel.size())
        }
    }
    
    function queryExplanationsFor(source, verseId)
    {
        var translation = persist.getValueFor("translation");
        
        if (translation == "english")
        {
            sourceSet = source;
            
            sqlDataSource.query = "SELECT id,verse_id,description FROM tafsir_english WHERE surah_id=%1 AND verse_id=%2".arg(chapterNumber).arg(verseId);
            sqlDataSource.load(0);   
        }
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
        },
        
        RangeSelector {
            itemName: qsTr("ayahs")
        },
        
        PlainTextMultiselector
        {
            function getSelectedTextualData()
            {
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
        }
    ]
    
    animations: FadeTransition {
        id: fader
        toOpacity: 1
    }

    listItemComponents: [

        ListItemComponent {
            type: "header"
            
            CanadaIncHeaderListItem {
                id: headerRoot
                labelValue: qsTr("%1:%2").arg(headerRoot.ListItem.view.chapterNumber).arg(ListItemData)
            }
        },

        ListItemComponent {
            type: "item"

            Container {
                property bool selection: ListItem.selected
                property bool active: ListItem.active
                property bool hasTafsir: ListItemData.hasTafsir ? ListItemData.hasTafsir : false
                property bool playing: ListItemData.playing ? ListItemData.playing : false

                id: itemRoot

                function updateState()
                {
                    if (playing) {
                        background = Color.create("#ffff8c00")
                    } else if (selection || active) {
                        background = Color.DarkGreen
                    } else if (hasTafsir) {
                        background = Color.create("#ffe0e0e0")
                    } else {
                        background = undefined
                    }
                }
                
                onCreationCompleted: {
                    selectionChanged.connect(updateState);
                    playingChanged.connect(updateState);
                    activeChanged.connect(updateState);
                    hasTafsirChanged.connect(updateState);
                    updateState();
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
                    } else {
                        itemRoot.ListItem.view.queryExplanationsFor(actionSet, ListItemData.verse_id);
                    }
                }

                contextActions: [
                    PlainTextActionSet {
                        id: actionSet
                        listItemRoot: itemRoot
                        title: firstLabel.text
                        subtitle: labelDelegate.delegateActive ? labelDelegate.control.text : qsTr("%1:%2").arg(itemRoot.ListItem.view.chapterNumber).arg(ListItemData.verse_id)

                        ActionItem {
                            title: qsTr("Bookmark") + Retranslate.onLanguageChanged
                            imageSource: "images/ic_bookmark_add.png"

                            onTriggered: {
                                itemRoot.ListItem.view.bookmark(ListItemData)
                            }
                        }

                        ActionItem {
                            id: playFromHere

                            title: qsTr("Play From Here") + Retranslate.onLanguageChanged
                            imageSource: "images/ic_play.png"

                            onTriggered: {
                                var n = itemRoot.ListItem.view.dataModel.size();
                                var downloaded = itemRoot.ListItem.view.fileExists(n);

                                if (!downloaded) {
                                    itemRoot.ListItem.view.download();
                                } else {
                                    var result = [];

                                    for (var i = ListItemData.verse_id; i <= n; i++) {
                                        result.push(i);
                                    }
                                    
                                    itemRoot.ListItem.view.play(result);
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
                    delegateActive: ListItemData.translation ? true : false
                    horizontalAlignment: HorizontalAlignment.Fill
                    sourceComponent: ComponentDefinition
                    {
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
                }
            }
        }
    ]
}