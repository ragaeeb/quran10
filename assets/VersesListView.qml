import QtQuick 1.0
import bb.cascades 1.2
import com.canadainc.data 1.0

ListView
{
    id: listView
    property alias theDataModel: verseModel
    property alias activeDefinition: activeDef
    property int chapterNumber
    property int translationSize: helper.translationSize
    property int primarySize: helper.primarySize
    property int previousPlayedIndex
    property bool secretPeek: false
    property bool follow
    property bool showContextMenu: true
    property bool scrolled: false
    property bool blockPeek: false
    property bool showImages
    scrollRole: ScrollRole.Main

    dataModel: ArrayDataModel {
        id: verseModel
    }
    
    onScrolledChanged: {
        if (scrolled) {
            timer.restart();
        }
    }
    
    leadingVisual: BismillahControl {
        delegateActive: chapterNumber > 1 && chapterNumber != 9
    }
    
    function play(from, to)
    {
        clearPrevious();
        previousPlayedIndex = -1;
        recitation.downloadAndPlayAll(verseModel, from, to);
    }
    
    onSelectionChanged: {
        var n = selectionList().length;
        multiPlayAction.enabled = n > 0;
    }
    
    function itemType(data, indexPath)
    {
        if (helper.showTranslation) {
            return showImages ? "imageTrans" : "trans";
        } else {
            return showImages ? "image" : "text";
        }
    }

    multiSelectHandler
    {
        actions: [
            ActionItem
            {
                id: multiPlayAction
                enabled: false
                title: qsTr("Play") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_play.png"

                onTriggered: {
                    console.log("UserEvent: MultiPlay");
                    var selectedIndices = listView.selectionList();
                    var first = selectedIndices[0][0];
                    var last = selectedIndices[selectedIndices.length-1][0];

                    play(first, last);
                }
            },
            
            ActionItem
            {
                id: multiCopy
                enabled: multiPlayAction.enabled
                title: qsTr("Copy") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_copy.png"
                
                onTriggered: {
                    console.log("UserEvent: MultiCopy");
                    persist.copyToClipboard( app.textualizeAyats(verseModel, selectionList(), ctb.text) );
                }
            },
            
            InvokeActionItem
            {
                id: multiShare
                enabled: multiPlayAction.enabled
                imageSource: "images/menu/ic_share.png"
                title: qsTr("Share") + Retranslate.onLanguageChanged
                
                query {
                    mimeType: "text/plain"
                    invokeActionId: "bb.action.SHARE"
                }
                
                onTriggered: {
                    console.log("UserEvent: MultiShare");
                    data = persist.convertToUtf8( app.textualizeAyats(verseModel, selectionList(), ctb.text) );
                }
            }
        ]

        status: qsTr("None selected") + Retranslate.onLanguageChanged
    }
    
    function clearPrevious()
    {
        var data = verseModel.value(previousPlayedIndex);
        data.playing = false;
        verseModel.replace(previousPlayedIndex, data);
    }
    
    function onMetaDataChanged(metaData)
    {
        var index = recitation.extractIndex(metaData);
        
        if (previousPlayedIndex >= 0) {
            clearPrevious();
        }
        
        if (index == -1) {
            return;
        }
        
        var target = index;
        var data = dataModel.value(target);
        
        data["playing"] = true;
        verseModel.replace(target, data);
        
        if (follow) {
            listView.scrollToItem([target], ScrollAnimation.None);
        }
        
        previousPlayedIndex = index;
    }
    
    onCreationCompleted: {
        persist.settingChanged.connect(onSettingChanged);
        player.metaDataChanged.connect(onMetaDataChanged);
        player.playbackCompleted.connect(clearPrevious);
        
        onSettingChanged("follow");
        onSettingChanged("overlayAyatImages");
    }

    function onSettingChanged(key)
    {
        if (key == "follow") {
            follow = persist.getValueFor("follow") == 1;
        } else if (key == "overlayAyatImages") {
            showImages = persist.getValueFor("overlayAyatImages") == 1;
        }
    }
    
    function memorize(from)
    {
        if (previousPlayedIndex >= 0) {
            clearPrevious();
        }
        
        previousPlayedIndex = -1;
        var end = Math.min( from+8, dataModel.size() );
        
        recitation.memorize(verseModel, from, end);
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.SaveLastProgress) {
            persist.showToast( qsTr("Successfully saved bookmark!"), "", "asset:///images/menu/ic_bookmark_add.png" );
            global.lastPositionUpdated();
        }
    }
    
    function setBookmark(ListItemData) {
        bookmarkHelper.saveLastProgress(listView, ListItemData.surah_id, ListItemData.verse_id);
    }
    
    function refresh()
    {
        for (var j = verseModel.size()-1; j >= 0; j--) {
            verseModel.replace( j, verseModel.value(j) );
        }
    }

    listItemComponents: [
        ListItemComponent
        {
            type: "image"
            AyatImageListItem {}
        },
        
        ListItemComponent
        {
            type: "imageTrans"
            AyatImageTranslationListItem {}
        },
        
        ListItemComponent
        {
            type: "trans"
            AyatTranslationListItem {}
        },
        
        ListItemComponent
        {
            type: "text"
            AyatListItem {}
        }
    ]
    
    attachedObjects: [
        RangeSelector {
            itemName: qsTr("ayahs")
        },
        
        ImagePaintDefinition
        {
            id: activeDef
            imageSource: "images/list_item_pressed.amd"
        },
        
        Timer {
            id: timer
            interval: 150
            running: false
            repeat: false
            
            onTriggered: {
                scrolled = false;
            }
        }
    ]
}