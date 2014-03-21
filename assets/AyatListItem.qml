import bb.cascades 1.2

Container
{
    property bool selection: ListItem.selected
    property bool hasTafsir: ListItemData.hasTafsir ? ListItemData.hasTafsir : false
    property bool playing: ListItemData.playing ? ListItemData.playing : false
    property bool active: ListItem.active
    
    id: itemRoot
    
    function updateState()
    {
        if (playing) {
            background = Color.create("#ffff8c00")
        } else if (selection) {
            background = Color.DarkGreen
        } else if (hasTafsir) {
            background = Color.create("#ffe0e0e0")
        } else if (active) {
            background = ListItem.view.activeDefinition.imagePaint
        } else {
            background = undefined
        }
    }
    
    onCreationCompleted: {
        selectionChanged.connect(updateState);
        playingChanged.connect(updateState);
        hasTafsirChanged.connect(updateState);
        activeChanged.connect(updateState);
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
        PlainTextActionSet
        {
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
                title: qsTr("Add to Home Screen") + Retranslate.onLanguageChanged
                imageSource: "images/ic_home.png"
                
                onTriggered: {
                    itemRoot.ListItem.view.addToHomeScreen(ListItemData)
                }
            }
            
            ActionItem {
                id: playFromHere
                
                title: qsTr("Play From Here") + Retranslate.onLanguageChanged
                imageSource: "images/ic_play.png"
                
                onTriggered: {
                    itemRoot.ListItem.view.mediaPlayer.doPlay( itemRoot.ListItem.indexPath[0]+1, itemRoot.ListItem.view.dataModel.size() );
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
        
        textStyle {
            color: selection || playing ? Color.White : Color.Black;
            base: itemRoot.ListItem.view.custom.style;
            fontFamily: "uthman_bold";
            textAlign: TextAlign.Center;
            
            fontSize: {
                var primary = itemRoot.ListItem.view.primarySize;
                
                if (primary == 1) {
                    return FontSize.Small;
                } else if (primary == 2) {
                    return FontSize.Medium;
                } else {
                    return FontSize.XXLarge;
                }
            }
        }
    }
    
    ControlDelegate
    {
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
                textStyle.color: selection || playing ? Color.White : Color.Black
                textStyle.textAlign: TextAlign.Center
                visible: text.length > 0;
                textStyle.fontSize: {
                    var translationSize = itemRoot.ListItem.view.translationSize;
                    
                    if (translationSize == 1) {
                        return FontSize.Small;
                    } else if (translationSize == 2) {
                        return FontSize.Medium;
                    } else {
                        return FontSize.XXLarge;
                    }
                }
            }
        }
    }
}