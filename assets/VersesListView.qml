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