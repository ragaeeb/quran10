import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    function popToRoot()
    {
        while (navigationPane.top != individualPicker) {
            navigationPane.pop();
        }
    }
    
    function onCreate(id, prefix, name, kunya, displayName, hidden, birth, death, female, location)
    {
        tafsirHelper.createIndividual(navigationPane, prefix, name, kunya, displayName, birth, death, location);
        popToRoot();
    }
    
    function onEdit(id, prefix, name, kunya, displayName, hidden, birth, death, female, location)
    {
        tafsirHelper.editIndividual(navigationPane, id, prefix, name, kunya, displayName, hidden, birth, death, female, location);
        
        var obj = {'id': id, 'prefix': prefix, 'name': name, 'kunya': kunya, 'displayName': displayName, 'hidden': hidden ? 1 : 0, 'female': female ? 1 : 0};
        
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
        if (id == QueryId.AddIndividual)
        {
            persist.showToast( qsTr("Individual added!"), "asset:///images/menu/ic_add_suite.png" );
            individualPicker.fetchAllIndividuals(individualPicker.pickerList);
        } else if (id == QueryId.CopyIndividualsFromSource) {
            persist.showToast( qsTr("Successfully ported individuals!"), "asset:///images/dropdown/ic_save_individual.png" );
        }  else if (id == QueryId.EditIndividual) {
            persist.showToast( qsTr("Successfully edited individual"), "asset:///images/dropdown/ic_save_individual.png" );
        } else if (id == QueryId.AddIndividual) {
            persist.showToast( qsTr("Successfully added individual"), "asset:///images/dropdown/ic_save_individual.png" );
        } else if (id == QueryId.RemoveIndividual) {
            persist.showToast( qsTr("Successfully deleted individual!"), "asset:///images/menu/ic_delete_quote.png" );
        } else if (id == QueryId.ReplaceIndividual) {
            persist.showToast( qsTr("Successfully replaced individual!"), "asset:///images/menu/ic_delete_quote.png" );
            individualPicker.fetchAllIndividuals(individualPicker.pickerList);
        } else if (id == QueryId.AddCompanions) {
            persist.showToast( qsTr("Successfully added companions!"), "asset:///images/menu/ic_set_companions.png" );
        } else if (id == QueryId.RemoveCompanions) {
            persist.showToast( qsTr("Successfully removed from companions!"), "asset:///images/menu/ic_remove_companions.png" );
        } else if (id == QueryId.AddBio) {
            persist.showToast( qsTr("Successfully added biography!"), "asset:///images/menu/ic_add_bio.png" );
        }
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
        
        onCreationCompleted: {
            performSearch();
        }
        
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
                id: copyAction
                imageSource: "images/menu/ic_copy_from_english.png"
                title: qsTr("Copy From English") + Retranslate.onLanguageChanged
                enabled: helper.translation != "english"
                
                function onFinished(confirmed, remember)
                {
                    if (confirmed)
                    {
                        console.log("UserEvent: CopyIndividualsFromEnglishResult", confirmed, remember);

                        if (remember) {
                            helper.replaceIndividualsFromSource(individualPicker.pickerList, "english");
                        } else {
                            helper.copyIndividualsFromSource(individualPicker.pickerList, "english");
                        }
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: CopyIndividualsFromEnglish");
                    persist.showDialog( copyAction, qsTr("Confirmation"), qsTr("Are you sure you want to port over the data from the source database?"), qsTr("Yes"), qsTr("No"), qsTr("Replace Existing") );
                }
            }
        ]
        
        function onBioSaved(data)
        {
            tafsirHelper.addBio(navigationPane, data.target, data.body, data.reference, data.author_id, data.points);
            popToRoot();
        }
        
        function addBio(ListItemData)
        {
            definition.source = "CreateBioPage.qml";
            var page = definition.createObject();
            page.createBio.connect(onBioSaved);
            page.data = {'target': ListItemData.id};
            
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
                persist.showToast( qsTr("The source and replacement individuals cannot be the same!"), "asset:///images/toast/ic_duplicate_replace.png" );
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
        
        pickerList.multiSelectAction: MultiSelectActionItem {
            imageSource: "images/menu/ic_select_individuals.png"
        }
        
        pickerList.onSelectionChanged: {
            var n = individualPicker.pickerList.selectionList().length;
            individualPicker.pickerList.multiSelectHandler.status = qsTr("%n individuals selected", "", n);
            setCompanions.enabled = n > 0;
        }
        
        pickerList.multiSelectHandler.actions: [
            ActionItem
            {
                id: setCompanions
                imageSource: "images/menu/ic_set_companions.png"
                title: qsTr("Set As Companions") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: SetCompanions");
                    tafsirHelper.addCompanions( navigationPane, getSelectedIds() );
                    
                    var all = individualPicker.pickerList.selectionList();
                    
                    for (var i = all.length-1; i >= 0; i--)
                    {
                        var c = individualPicker.model.data(all[i]);
                        c["companion_id"] = c.id;
                        individualPicker.model.replace(all[i][0], c);
                    }
                }
            },
            
            DeleteActionItem
            {
                id: removeCompanions
                enabled: setCompanions.enabled
                imageSource: "images/menu/ic_remove_companions.png"
                title: qsTr("Remove Companions") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: RemoveCompanions");
                    tafsirHelper.removeCompanions( navigationPane, getSelectedIds() );
                    
                    var all = individualPicker.pickerList.selectionList();
                    
                    for (var i = all.length-1; i >= 0; i--)
                    {
                        var c = individualPicker.model.data(all[i]);
                        delete c["companion_id"];
                        individualPicker.model.replace(all[i][0], c);
                    }
                }
            }
        ]
        
        pickerList.listItemComponents: [
            ListItemComponent
            {
                IndividualListItem
                {
                    id: sli
                    
                    contextActions: [
                        ActionSet
                        {
                            title: sli.title
                            subtitle: sli.description

                            ActionItem
                            {
                                id: addBio
                                imageSource: "images/menu/ic_add_bio.png"
                                title: qsTr("Add Biography") + Retranslate.onLanguageChanged
                                
                                onTriggered: {
                                    console.log("UserEvent: AddBio");
                                    sli.ListItem.view.pickerPage.addBio(ListItemData);
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