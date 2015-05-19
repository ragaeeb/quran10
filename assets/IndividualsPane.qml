import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    function popToRoot()
    {
        while (navigationPane.top != individualPicker) {
            navigationPane.pop();
        }
    }
    
    function onCreate(id, prefix, name, kunya, displayName, hidden, birth, death, female, location, companion)
    {
        id = tafsirHelper.createIndividual(navigationPane, prefix, name, kunya, displayName, birth, death, location, companion);
        popToRoot();
        
        var obj = {'id': id, 'name': name, 'hidden': hidden ? 1 : undefined, 'female': female ? 1 : undefined, 'is_companion': companion ? 1 : undefined};
        
        if (displayName.length > 0) {
            obj["name"] = displayName;
        }
        
        if (birth > 0) {
            obj["birth"] = birth;
        }
        
        if (death > 0) {
            obj["death"] = death;
        }
        
        if (location.length > 0) {
            obj["location"] = location;
        }
        
        individualPicker.model.insert(0, obj);
    }
    
    function onEdit(id, prefix, name, kunya, displayName, hidden, birth, death, female, location, companion)
    {
        tafsirHelper.editIndividual(navigationPane, id, prefix, name, kunya, displayName, hidden, birth, death, female, location, companion);
        
        var obj = {'id': id, 'name': name, 'hidden': hidden ? 1 : undefined, 'female': female ? 1 : undefined, 'is_companion': companion ? 1 : undefined};
        
        if (displayName.length > 0) {
            obj["name"] = displayName;
        }
        
        if (birth > 0) {
            obj["birth"] = birth;
        }
        
        if (death > 0) {
            obj["death"] = death;
        }
        
        if (location > 0) {
            obj["location"] = location;
        }
        
        individualPicker.model.replace(individualPicker.editIndexPath[0], obj);
        popToRoot();
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.EditIndividual) {
            persist.showToast( qsTr("Successfully edited individual"), "images/menu/ic_edit_rijaal.png" );
        } else if (id == QueryId.AddIndividual) {
            persist.showToast( qsTr("Successfully added individual"), "images/menu/ic_select_individuals.png" );
        } else if (id == QueryId.RemoveIndividual) {
            persist.showToast( qsTr("Successfully deleted individual!"), "images/menu/ic_delete_individual.png" );
        } else if (id == QueryId.ReplaceIndividual) {
            persist.showToast( qsTr("Successfully replaced individual!"), "images/menu/ic_delete_quote.png" );
            tafsirHelper.fetchAllIndividuals(individualPicker.pickerList);
        } else if (id == QueryId.AddBioLink) {
            persist.showToast( qsTr("Successfully added biography!"), "images/menu/ic_add_bio.png" );
        }
        
        individualPicker.refresh();
    }
    
    function getSelectedIds()
    {
        var all = individualPicker.pickerList.selectionList();
        var ids = [];
        
        for (var i = all.length-1; i >= 0; i--) {
            ids.push( individualPicker.model.data( all[i] ).id );
        }
        
        return ids;
    }
    
    IndividualPickerPage
    {
        id: individualPicker
        property variant toReplaceId
        property variant editIndexPath
        
        onContentLoaded: {
            navigationPane.parent.unreadContentCount = size;
        }
        
        actions: [
            ActionItem
            {
                id: addAction
                imageSource: "images/menu/ic_add_rijaal.png"
                title: qsTr("Add") + Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.OnBar
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.CreateNew
                    }
                ]
                
                onTriggered: {
                    console.log("UserEvent: NewIndividual");
                    definition.source = "CreateIndividualPage.qml";
                    var page = definition.createObject();
                    page.createIndividual.connect(onCreate);
                    
                    navigationPane.push(page);
                }
            },
            
            ActionItem
            {
                id: bios
                imageSource: "images/tabs/ic_bio.png"
                title: qsTr("Biographies") + Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: Biographies");
                    definition.source = "BiographiesPage.qml";
                    var page = definition.createObject();
                    page.reload();
                    navigationPane.push(page);
                }
            }
        ]
        
        function onBioSaved(id, author, heading, body, reference)
        {
            var id = tafsirHelper.addBio(navigationPane, body, reference, author, heading);
            tafsirHelper.addBioLink(navigationPane, id, pickerList.dataModel.data(editIndexPath).id, undefined);
            popToRoot();
        }
        
        function addBio(ListItem)
        {
            editIndexPath = ListItem.indexPath;
            definition.source = "CreateBioPage.qml";
            var page = definition.createObject();
            page.createBio.connect(onBioSaved);
            
            navigationPane.push(page);
        }
        
        function edit(ListItem)
        {
            editIndexPath = ListItem.indexPath;
            definition.source = "CreateIndividualPage.qml";
            var page = definition.createObject();
            page.individualId = ListItem.data.id;
            page.createIndividual.connect(onEdit);
            
            navigationPane.push(page);
        }
        
        function removeItem(ListItem)
        {
            individualPicker.busyControl.delegateActive = true;
            tafsirHelper.removeIndividual(navigationPane, ListItem.data.id);
            individualPicker.model.removeAt(ListItem.indexPath[0]);
        }
        
        function onActualPicked(actualId)
        {
            if (actualId != toReplaceId)
            {
                individualPicker.busyControl.delegateActive = true;
                tafsirHelper.replaceIndividual(navigationPane, toReplaceId, actualId);
            } else {
                notification.init( qsTr("The source and replacement individuals cannot be the same!"), "images/toast/ic_duplicate_replace.png" );
            }
            
            popToRoot();
        }
        
        function replace(ListItemData)
        {
            toReplaceId = ListItemData.id;
            definition.source = "IndividualPickerPage.qml";
            var ipp = definition.createObject();
            ipp.picked.connect(onActualPicked);
            
            navigationPane.push(ipp);
        }
        
        pickerList.listItemComponents: [
            ListItemComponent
            {
                StandardListItem
                
                {
                    id: sli
                    imageSource: ListItemData.is_companion ? "images/list/ic_companion.png" : "images/list/ic_individual.png"
                    title: ListItemData.name
                    
                    contextActions: [
                        ActionSet
                        {
                            title: sli.title
                            subtitle: sli.description

                            ActionItem
                            {
                                imageSource: "images/menu/ic_add_bio.png"
                                title: qsTr("Add Biography") + Retranslate.onLanguageChanged
                                
                                onTriggered: {
                                    console.log("UserEvent: NewBio");
                                    sli.ListItem.view.pickerPage.addBio(sli.ListItem);
                                }
                            }

                            ActionItem
                            {
                                imageSource: "images/menu/ic_copy.png"
                                title: qsTr("Copy") + Retranslate.onLanguageChanged
                                
                                onTriggered: {
                                    console.log("UserEvent: CopyIndividual");
                                    var result = "";
                                    
                                    if (ListItemData.prefix) {
                                        result += ListItemData.prefix+" ";
                                    }
                                    
                                    result += ListItemData.name;
                                    
                                    if (ListItemData.kunya) {
                                        result += " "+ListItemData.kunya;
                                    }
                                    
                                    persist.copyToClipboard(result);
                                }
                            }
                            
                            ActionItem
                            {
                                imageSource: "images/menu/ic_edit_rijaal.png"
                                title: qsTr("Edit") + Retranslate.onLanguageChanged
                                
                                onTriggered: {
                                    console.log("UserEvent: EditIndividual");
                                    sli.ListItem.view.pickerPage.edit(sli.ListItem);
                                }
                            }
                            
                            ActionItem
                            {
                                imageSource: "images/menu/ic_replace_individual.png"
                                title: qsTr("Replace") + Retranslate.onLanguageChanged
                                
                                onTriggered: {
                                    console.log("UserEvent: ReplaceIndividual");
                                    sli.ListItem.view.pickerPage.replace(ListItemData);
                                }
                            }
                            
                            DeleteActionItem
                            {
                                imageSource: "images/menu/ic_delete_individual.png"
                                
                                onTriggered: {
                                    console.log("UserEvent: DeleteIndividual");
                                    sli.ListItem.view.pickerPage.removeItem(sli.ListItem);
                                }
                            }
                        }
                    ]
                }
            }
        ]
        
        onPicked: {
            definition.source = "IndividualBioPage.qml";
            var page = definition.createObject();
            page.individualId = individualId;
            
            navigationPane.push(page);
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}