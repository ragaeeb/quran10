import bb.cascades 1.2
import com.canadainc.data 1.0

ListView
{
    id: listView
    property alias theDataModel: verseModel
    property alias background: headerBackground
    property alias activeDefinition: activeDef
    property int chapterNumber
    property int translationSize: helper.translationSize
    property int primarySize: helper.primarySize
    property int previousPlayedIndex
    property bool secretPeek: false
    property bool follow: persist.getValueFor("follow") == 1
    property bool showContextMenu: true

    dataModel: ArrayDataModel {
        id: verseModel
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

    multiSelectHandler {
        actions: [
            ActionItem
            {
                id: multiPlayAction
                enabled: false
                title: qsTr("Play") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_play.png"

                onTriggered: {
                    console.log("UserEvent: MultiPlayTriggered");
                    var selectedIndices = listView.selectionList();
                    var first = selectedIndices[0][0];
                    var last = selectedIndices[selectedIndices.length-1][0];

                    play(first, last);
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

    attachedObjects: [
        ImagePaintDefinition
        {
            id: headerBackground
            imageSource: "images/backgrounds/header_bg.png"
        },
        
        RangeSelector {
            itemName: qsTr("ayahs")
        },
        
        ImagePaintDefinition
        {
            id: activeDef
            imageSource: "images/list_item_pressed.amd"
        }
    ]
    
    listItemComponents: [
        ListItemComponent
        {
            AyatListItem
            {
                id: ali
                
                contextMenuHandler: [
                    ContextMenuHandler {
                        onPopulating: {
                            if (!ali.ListItem.view.showContextMenu) {
                                event.abort();
                            }
                        }
                    }
                ]
                
                contextActions: [
                    ActionSet
                    {
                        id: actionSet
                        title: ListItemData.arabic
                        subtitle: ali.secondLine.delegateActive ? ali.secondLine.control.text : qsTr("%1:%2").arg(ali.ListItem.view.chapterNumber).arg(ListItemData.verse_id)
                        
                        ActionItem
                        {
                            title: qsTr("Memorize") + Retranslate.onLanguageChanged
                            imageSource: "images/menu/ic_memorize.png"
                            
                            onTriggered: {
                                console.log("UserEvent: MemorizeAyat");
                                ali.ListItem.view.memorize( ali.ListItem.indexPath[0] );
                            }
                        }
                        
                        ActionItem {
                            id: playFromHere
                            
                            title: qsTr("Play From Here") + Retranslate.onLanguageChanged
                            imageSource: "images/menu/ic_play.png"
                            
                            onTriggered: {
                                console.log("UserEvent: PlayFromHere");
                                ali.ListItem.view.play(ali.ListItem.indexPath[0], -1);
                            }
                        }
                        
                        ActionItem
                        {
                            title: qsTr("Set Bookmark") + Retranslate.onLanguageChanged
                            imageSource: "images/menu/ic_bookmark_add.png"
                            
                            onTriggered: {
                                console.log("UserEvent: SetBookmark");
                                ali.ListItem.view.setBookmark(ali.ListItem.data);
                            }
                        }
                    }
                ]
            }
        }
    ]
}