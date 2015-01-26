import bb.cascades 1.2
import bb.system 1.0
import com.canadainc.data 1.0

ListView
{
    id: listView
    property alias theDataModel: verseModel
    property alias background: headerBackground
    property alias activeDefinition: activeDef
    property int chapterNumber
    property string chapterName
    property int translationSize: helper.translationSize
    property int primarySize: helper.primarySize
    property alias custom: customTextStyle
    property int previousPlayedIndex
    property bool secretPeek: false
    property bool follow: persist.getValueFor("follow") == 1

    dataModel: GroupDataModel
    {
        id: verseModel
        sortingKeys: [ "verse_id" ]
        grouping: ItemGrouping.ByFullValue
    }
    
    leadingVisual: BismillahControl {
        delegateActive: chapterNumber > 1 && chapterNumber != 9
    }
    
    function play(from, to)
    {
        clearPrevious();
        previousPlayedIndex = -1;
        recitation.downloadAndPlay(chapterNumber, from, to);
    }

    multiSelectHandler {
        actions: [
            ActionItem {
                id: multiPlayAction

                title: qsTr("Play") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_play.png"

                onTriggered: {
                    console.log("UserEvent: MultiPlayTriggered");
                    var selectedIndices = listView.selectionList();
                    var first = selectedIndices[0][0];
                    var last = selectedIndices[selectedIndices.length-1][0];
                    
                    play(first+1, last+1);
                }
            }
        ]

        status: qsTr("None selected") + Retranslate.onLanguageChanged
    }
    
    function clearPrevious()
    {
        var actual = [ previousPlayedIndex, 0 ];
        var data = verseModel.data(actual);
        data.playing = false;
        verseModel.updateItem(actual, data);
    }
    
    function onMetaDataChanged(metaData)
    {
        var index = recitation.extractIndex(metaData);
        
        if (previousPlayedIndex >= 0) {
            clearPrevious();
        }
        
        var target = [ index-1, 0 ];
        var data = dataModel.data(target);
        
        data["playing"] = true;
        verseModel.updateItem(target, data);
        
        if (follow) {
            listView.scrollToItem(target, ScrollAnimation.None);
        }
        
        previousPlayedIndex = index-1;
    }
    
    onCreationCompleted: {
        persist.settingChanged.connect(settingChanged);
        player.metaDataChanged.connect(onMetaDataChanged);
        player.playbackCompleted.connect(clearPrevious);
    }

    function settingChanged(key)
    {
        if (key == "follow") {
            follow = persist.getValueFor("follow") == 1;
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

    function copyItem(ListItemData)
    {
        var result = getTextualData(ListItemData)
        persist.copyToClipboard(result)
    }

    function shareItem(ListItemData)
    {
        var result = getTextualData(ListItemData)
        result = persist.convertToUtf8(result)
        return result;
    }

    function bookmark(ListItemData)
    {
        prompt.data = ListItemData;
        prompt.body = qsTr("Enter a name for this bookmark");
        prompt.inputField.maximumLength = 50;
        prompt.show();
    }
    
    function addToHomeScreen(ListItemData)
    {
        prompt.data = ListItemData;
        prompt.body = qsTr("Enter a name for this shortcut:");
        prompt.inputField.maximumLength = 15;
        prompt.show();
    }
    
    function memorize(from)
    {
        if (previousPlayedIndex >= 0) {
            clearPrevious();
        }
        
        previousPlayedIndex = -1;
        var end = Math.min( from+1+8, dataModel.size() );
        
        recitation.memorize(chapterNumber, from+1, end);
    }
    
    function refresh()
    {
        var sections = verseModel.childCount([]);
        
        for (var i = 0; i < sections; i++)
        {
            var childrenInSection = verseModel.childCount([i]);
            
            for (var j = 0; j < childrenInSection; j++)
            {
                var indexPath = [i,j];
                var current = verseModel.data(indexPath).toMap();
                varModel.updateItem(indexPath, current);
            }
        }
    }

    attachedObjects: [
        ImagePaintDefinition
        {
            id: headerBackground
            imageSource: "images/backgrounds/header_bg.png"
        },
        
        TextStyleDefinition
        {
            id: customTextStyle

            rules: [
                FontFaceRule {
                    id: baseStyleFontRule
                    source: "fonts/me_quran.ttf"
                    fontFamily: "Regular"
                }
            ]
        },
        
        RangeSelector {
            itemName: qsTr("ayahs")
        },
        
        ImagePaintDefinition
        {
            id: activeDef
            imageSource: "images/list_item_pressed.amd"
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
        },
        
        SystemPrompt
        {
            id: prompt
            property variant data
            title: qsTr("Enter Name") + Retranslate.onLanguageChanged
            inputField.emptyText: qsTr("Enter a meaningful name...") + Retranslate.onLanguageChanged
            confirmButton.label: qsTr("OK") + Retranslate.onLanguageChanged
            cancelButton.label: qsTr("Cancel") + Retranslate.onLanguageChanged
            inputField.defaultText: data ? "(%1:%2) %3".arg(chapterNumber).arg(data.verse_id).arg(data.translation ? data.translation : data.arabic) : ""
            
            function onDataLoaded(id, data) 
            {
                if (id == QueryId.SaveBookmark) {
                    persist.showToast( qsTr("Bookmarked %1:%2").arg(chapterName).arg(data.verse_id), "", "asset:///images/menu/ic_bookmark_add.png" );
                }
            }
            
            onFinished: {
                if (result == SystemUiResult.ConfirmButtonSelection)
                {
                    var bookmarkName = inputFieldTextEntry().trim();
                    
                    if (inputField.maximumLength > 15) { // bookmark
                        helper.saveBookmark(prompt, chapterNumber, data.verse_id, bookmarkName, "");
                    } else {
                        app.addToHomeScreen(chapterNumber, data.verse_id, bookmarkName);
                    }
                }
            }
        }
    ]
    
    listItemComponents: [
        ListItemComponent
        {
            type: "header"
            
            AyatHeaderListItem {
                id: headerRoot
                labelValue: qsTr("%1:%2").arg(headerRoot.ListItem.view.chapterNumber).arg(ListItemData)
            }
        },

        ListItemComponent
        {
            type: "item"

			AyatListItem
			{
			    id: ali
			    
                contextActions: [
                    ActionSet
                    {
                        id: actionSet
                        title: ListItemData.arabic
                        subtitle: ali.secondLine.delegateActive ? ali.secondLine.control.text : qsTr("%1:%2").arg(ali.ListItem.view.chapterNumber).arg(ListItemData.verse_id)
                        
                        ActionItem {
                            id: playFromHere
                            
                            title: qsTr("Play From Here") + Retranslate.onLanguageChanged
                            imageSource: "images/menu/ic_play.png"
                            
                            onTriggered: {
                                console.log("UserEvent: PlayFromHere");
                                ali.ListItem.view.play( ali.ListItem.indexPath[0]+1, ali.ListItem.view.dataModel.size() );
                            }
                        }
                        
                        ActionItem {
                            title: qsTr("Bookmark") + Retranslate.onLanguageChanged
                            imageSource: "images/menu/ic_bookmark_add.png"
                            
                            onTriggered: {
                                console.log("UserEvent: BookmarkAyatListItem");
                                ali.ListItem.view.bookmark(ListItemData)
                            }
                        }
                        
                        ActionItem {
                            title: qsTr("Add to Home Screen") + Retranslate.onLanguageChanged
                            imageSource: "images/menu/ic_home.png"
                            
                            onTriggered: {
                                console.log("UserEvent: AddHomeScreenAyat");
                                ali.ListItem.view.addToHomeScreen(ListItemData)
                            }
                        }
                        
                        ActionItem
                        {
                            title: qsTr("Memorize") + Retranslate.onLanguageChanged
                            imageSource: "images/menu/ic_memorize.png"
                            
                            onTriggered: {
                                console.log("UserEvent: MemorizeAyat");
                                ali.ListItem.view.memorize( ali.ListItem.indexPath[0] );
                            }
                        }
                    }
                ]
			}
        }
    ]
}