import bb.cascades 1.3

Container
{
    id: itemRoot
    property bool peek: ListItem.view.secretPeek != undefined ? ListItem.view.secretPeek : false
    property bool playing: ListItemData.playing ? ListItemData.playing : false
    property alias actionSetSubtitle: actionSet.subtitle
    horizontalAlignment: HorizontalAlignment.Fill
    
    function updateState(selected)
    {
        if (playing) {
            background = Color.create("#ffff8c00");
        } else if (ListItem.selected) {
            background = Color.DarkGreen;
        } else if (ListItem.active) {
            background = ListItem.view.activeDefinition.imagePaint;
        } else {
            background = undefined;
        }
    }
    
    onCreationCompleted: {
        ListItem.activationChanged.connect(updateState);
        ListItem.selectionChanged.connect(updateState);
        playingChanged.connect(updateState);
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
            duration: Math.max( 200, Math.min( itemRoot.ListItem.indexPath[0]*300, 750 ) );
            easingCurve: StockCurve.QuadraticIn
        }
    ]
    
    ListItem.onInitializedChanged: {
        if (initialized) {
            showAnim.play();
        }
    }
    
    Container
    {
        id: headerRoot
        horizontalAlignment: HorizontalAlignment.Fill
        background: global.headerBackground.imagePaint
        topPadding: 5
        bottomPadding: 5
        leftPadding: 5
        
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        
        Label {
            id: headerLabel
            text: "%1:%2".arg(ListItemData.surah_id).arg(ListItemData.verse_id)
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
    
    contextMenuHandler: [
        ContextMenuHandler
        {
            id: cmh
            
            onPopulating: {
                if (!itemRoot.ListItem.view.showContextMenu) {
                    event.abort();
                } else {
                    var all = itemRoot.ListItem.view.selectionList();
                    
                    if (all && all.length > 0 && all[0] != itemRoot.ListItem.indexPath) {
                        itemRoot.ListItem.view.select(all[0], false);
                    }
                }
            }

            onVisualStateChanged: {
                if (cmh.visualState == ContextMenuVisualState.VisibleCompact)
                {
                    tutorial.exec("memorize", qsTr("Memorize: This mode begins the playback of the current verse followed by the next 7 verses 20 times each to help you memorize it."), HorizontalAlignment.Right, VerticalAlignment.Center, 0, ui.du(2), 0, 0, memorize.imageSource.toString(), "d");
                    tutorial.exec("playFromHere", qsTr("Play From Here: This begins playback of the recitation starting from this verse"), HorizontalAlignment.Right, VerticalAlignment.Center, 0, ui.du(2), 0, 0, playFromHere.imageSource.toString(), "d");
                    tutorial.exec("setBookmark", qsTr("You can use the Set Bookmark action to place a bookmark on this verse so you can resume your reading the next time right to this verse quickly."), HorizontalAlignment.Right, VerticalAlignment.Center, 0, ui.du(2), 0, 0, setBookmark.imageSource.toString(), "d");
                    tutorial.exec("selectRangeOption", qsTr("You can use the 'Select Range' action to only play recitations for those, or copy/share them to your contacts."), HorizontalAlignment.Right, VerticalAlignment.Center, 0, ui.du(2), 0, 0, "images/menu/ic_range.png", "d");
                }
            }
        }
    ]
    
    contextActions: [
        ActionSet
        {
            id: actionSet
            title: ListItemData.arabic
            subtitle: headerLabel.text
            
            ActionItem
            {
                id: memorize
                title: qsTr("Memorize") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_memorize.png"
                
                onTriggered: {
                    console.log("UserEvent: MemorizeAyat");
                    itemRoot.ListItem.view.memorize( itemRoot.ListItem.indexPath[0] );
                }
            }
            
            ActionItem {
                id: playFromHere
                
                title: qsTr("Play From Here") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_play.png"
                
                onTriggered: {
                    console.log("UserEvent: PlayFromHere");
                    itemRoot.ListItem.view.play(itemRoot.ListItem.indexPath[0], -1);
                }
            }
            
            ActionItem
            {
                id: setBookmark
                title: qsTr("Set Bookmark") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_bookmark_add.png"
                
                onTriggered: {
                    console.log("UserEvent: SetBookmark");
                    itemRoot.ListItem.view.setBookmark(itemRoot.ListItem.data);
                }
            }
        }
    ]
}