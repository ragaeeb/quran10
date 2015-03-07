import bb.cascades 1.0

Container
{
    id: itemRoot
    property bool peek: ListItem.view.secretPeek
    property bool playing: ListItemData.playing ? ListItemData.playing : false
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
        ListItem.activationChanged.connect(upateState);
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
        ContextMenuHandler {
            onPopulating: {
                if (!itemRoot.ListItem.view.showContextMenu) {
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
            subtitle: ali.secondLine ? ali.secondLine.text : headerLabel.text
            
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