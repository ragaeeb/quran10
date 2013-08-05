import bb.cascades 1.0

QtObject
{
    id: plainTextHandler

    property ActionItem multiCopyAction: ActionItem
    {
        title: qsTr("Copy") + Retranslate.onLanguageChanged
        enabled: false
        imageSource: "images/ic_copy.png"
        onTriggered: {
            var result = plainTextHandler.getSelectedTextualData();
            persist.copyToClipboard(result);
        }
    }

    property InvokeActionItem multiShareAction: InvokeActionItem
    {
        title: qsTr("Share") + Retranslate.onLanguageChanged
        
        query {
            mimeType: "text/plain"
            invokeActionId: "bb.action.SHARE"
        }
        
        onTriggered: {
            var result = plainTextHandler.getSelectedTextualData();
            result = persist.convertToUtf8(result);
            multiShareAction.data = result;
        }
    }
    
    function getSelectedTextualData() {
        return "";
    }
    
    onCreationCompleted: {
        parent.multiSelectHandler.addAction(multiCopyAction);
        parent.multiSelectHandler.addAction(multiShareAction);
    }
}