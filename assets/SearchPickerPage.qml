import bb.cascades 1.0

SearchPage
{
    id: searchPage
    property bool doAppend: false
    signal narrationsSelected(variant ids);
    
    listControl.onSelectionChanged: {
        var n = listControl.selectionList().length;
        var msh = listControl.multiSelectHandler;
        msh.status = qsTr("%n narrations selected", "", n);
        
        var numActions = msh.actionCount();
        var enableActions = n > 0;
        
        for (var i = 0; i < numActions; i++) {
            msh.actionAt(i).enabled = enableActions;
        }
    }
    
    listControl.multiSelectHandler.actions: [
        ActionItem
        {
            title: qsTr("Save") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_select_more.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: SearchPickerSaveActionTriggered");
                
                var all = searchPage.listControl.selectionList();
                var ids = [];
                var dm = searchPage.model;
                
                if (doAppend) {
                    for (var i = all.length-1; i >= 0; i--) {
                        ids.push( dm.data(all[i]) );
                    }
                } else {
                    for (var i = all.length-1; i >= 0; i--) {
                        ids.push( dm.data(all[i]).id );
                    }
                }
                
                narrationsSelected(ids);
            }
        }
    ]
    
    onItemTapped: {
        listControl.multiSelectHandler.active = true;
        listControl.toggleSelection(indexPath);
    }
    
    attachedObjects: [
        HadithLinkHelper {
            listView: searchPage.listControl
        }
    ]
}