import bb.cascades 1.0

Container
{
    id: itemRoot
    property bool peek: ListItem.view.secretPeek
    property bool selection: ListItem.selected
    property bool hasTafsir: ListItemData.hasTafsir ? ListItemData.hasTafsir : false
    property bool playing: ListItemData.playing ? ListItemData.playing : false
    property bool active: ListItem.active
    
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
    
    onPeekChanged: {
        if (peek) {
            showAnim.play();
        }
    }
    
    opacity: 0
    animations: [
        FadeTransition
        {
            id: showAnim
            fromOpacity: 0
            toOpacity: 1
            duration: Math.min( itemRoot.ListItem.indexPath[0]*300, 750 );
        }
    ]
    
    ListItem.onInitializedChanged: {
        if (initialized) {
            showAnim.play();
        }
    }
    
    contextActions: [
        PlainTextActionSet
        {
            id: actionSet
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
                    itemRoot.ListItem.view.play( itemRoot.ListItem.indexPath[0]+1, itemRoot.ListItem.view.dataModel.size() );
                }
            }
            
            ActionItem
            {
                title: qsTr("Memorize") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_memorize.png"
                
                onTriggered: {
                    itemRoot.ListItem.view.memorize( itemRoot.ListItem.indexPath[0] );
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
        
        textStyle {
            color: selection || playing ? Color.White : Color.Black;
            base: itemRoot.ListItem.view.custom.style;
            fontFamily: "uthman_bold";
            textAlign: TextAlign.Center;
            fontSizeValue: itemRoot.ListItem.view.primarySize
            fontSize: FontSize.PointValue
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