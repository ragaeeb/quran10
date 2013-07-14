import bb.cascades 1.0

ActionSet {
    id: actionSet
    property variant listItemRoot
    
    ActionItem {
        title: qsTr("Copy") + Retranslate.onLanguageChanged
        imageSource: "images/ic_copy.png"
        onTriggered: {
            listItemRoot.ListItem.view.copyItem(ListItemData)
        }
    }
    
    InvokeActionItem {
        id: iai
        title: qsTr("Share") + Retranslate.onLanguageChanged
        
        query {
            mimeType: "text/plain"
            invokeActionId: "bb.action.SHARE"
        }
        
        onTriggered: {
            iai.data = listItemRoot.ListItem.view.shareItem(ListItemData)
        }
    }
}