import bb.cascades 1.3

QtObject
{
    property string itemName
    property bool activated: false
    property MultiSelectActionItem msai: MultiSelectActionItem
    {
        title: qsTr("Select Range") + Retranslate.onLanguageChanged
        imageSource: "images/menu/ic_range.png"
        
        onTriggered: {
            activated = true;
            console.log("UserEvent: SelectRangeTriggered");
            tutorial.exec("selectRange", qsTr("Now select the last ayat that you want to perform the actions of the menu on.\n\nYou can also select an ayat above the current one to start there and end at the current one."), HorizontalAlignment.Center, VerticalAlignment.Center, 0, 0, 0, 0, undefined, "d");
            
            analytics.record("SelectRangeTriggered");
        }
    }

    function onSelectionChanged()
    {
        if (!activated) {
            return;
        }
        
        var all = parent.selectionList();
        
        if (!all) {
            all = [];
        }

        var n = all.length;
        
        if (n > 0)
        {
            var first = all[0][0];
            var last = all[n-1][0];
            
            for (var i = first; i < last; i ++) {
                parent.select([i], true);
            }
            
            parent.multiSelectHandler.status = qsTr("%n %1 selected", "", last-first+1).arg(itemName) + Retranslate.onLanguageChanged;
        }
        
        var multiActions = parent.multiSelectHandler.actions;
        
        for (var i = multiActions.length-1; i >= 0; i--) {
            multiActions[i].enabled = n > 0;
        }
    }
    
    onCreationCompleted: {
        parent.selectionChanged.connect(onSelectionChanged);
        parent.multiSelectAction = msai;
    }
}