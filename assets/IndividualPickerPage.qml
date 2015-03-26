import bb.cascades 1.2
import com.canadainc.data 1.0

Page
{
    id: individualPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property alias allowEditing: listView.showContextMenu
    signal picked(variant individualId)
    
    actions: [
        ActionItem {
            id: searchAction
            imageSource: "images/menu/ic_search_individual.png"
            title: qsTr("Search") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: SearchActionTriggered");
                performSearch();
            }
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Search
                }
            ]
        },
        
        ActionItem
        {
            id: addAction
            imageSource: "images/menu/ic_link_ayat_to_tafsir.png"
            title: qsTr("Add") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: CreateNewIndividual");
                createDelegate.active = true;
            }
        },
        
        ActionItem
        {
            id: copyAction
            imageSource: "images/menu/ic_copy_from_english.png"
            title: qsTr("Copy From English") + Retranslate.onLanguageChanged
            enabled: helper.translation != "english"
            
            onTriggered: {
                console.log("UserEvent: CopyIndividualsFromEnglish");
                
                var result = persist.showBlockingDialogWithRemember( qsTr("Confirmation"), qsTr("Are you sure you want to port over the data from the source database?"), qsTr("Replace Existing") );
                console.log("UserEvent: CopyIndividualsFromEnglishResult", result[0], result[1]);
                
                if (result[0])
                {
                    if (result[1]) {
                        helper.replaceIndividualsFromSource(listView, "english");
                    } else {
                        helper.copyIndividualsFromSource(listView, "english");
                    }
                }
            }
        }
    ]
    
    titleBar: TitleBar
    {
        id: tb
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties
        {
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                topPadding: 10; bottomPadding: 20; leftPadding: 10
                
                TextField
                {
                    id: searchField
                    hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    bottomMargin: 0
                    
                    input {
                        submitKey: SubmitKey.Search
                        flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                        submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                        
                        onSubmitted: {
                            performSearch();
                        }
                    }
                    
                    onCreationCompleted: {
                        input["keyLayout"] = 7;
                    }
                    
                    animations: [
                        TranslateTransition {
                            fromY: -150
                            toY: 0
                            easingCurve: StockCurve.QuarticInOut
                            duration: 200
                            
                            onCreationCompleted: {
                                play();
                            }
                            
                            onStarted: {
                                searchField.requestFocus();
                            }
                            
                            onEnded: {
                                deviceUtils.attachTopBottomKeys(individualPage, listView);
                            }
                        }
                    ]
                }
            }
            
            expandableArea.onExpandedChanged: {
                searchField.requestFocus();
            }
            
            expandableArea.content: Container
            {
                DropDown
                {
                    id: filter
                    title: qsTr("Filter") + Retranslate.onLanguageChanged
                    
                    Option {
                        description: qsTr("Display everyone") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/search_author.png"
                        text: qsTr("None") + Retranslate.onLanguageChanged
                        value: ""
                        selected: true
                    }
                    
                    Option {
                        description: qsTr("Sahabahs") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/search_quote_body.png"
                        text: qsTr("Companions") + Retranslate.onLanguageChanged
                        value: "companions"
                    }
                }
            }
        }
    }
    
    function performSearch()
    {
        var trimmed = searchField.text.trim();
        
        if (trimmed.length > 0)
        {
            busy.delegateActive = true;
            noElements.delegateActive = false;
            
            tafsirHelper.searchIndividuals(listView, trimmed);
        } else {
            tafsirHelper.fetchAllIndividuals(listView);
        }
    }
    
    onCreationCompleted: {
        tafsirHelper.fetchFrequentIndividuals(listView);
    }
    
    Container
    {
        layout: DockLayout {}
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
        
        EmptyDelegate
        {
            id: noElements
            graphic: "images/placeholders/empty_individuals.png"
            labelText: qsTr("No results found for your query. Try another query.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                searchField.requestFocus();
            }
        }
        
        ListView
        {
            id: listView
            property bool showContextMenu: false
            property variant toReplaceId
            scrollRole: ScrollRole.Main
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            function edit(indexPath)
            {
                editDelegate.indexPath = indexPath;
                editDelegate.active = true;
            }
            
            function removeItem(ListItemData) {
                busy.delegateActive = true;
                tafsirHelper.removeIndividual(listView, ListItemData.id);
            }
            
            function onActualPicked(actualId)
            {
                if (actualId != toReplaceId)
                {
                    busy.delegateActive = true;
                    tafsirHelper.replaceIndividual(listView, toReplaceId, actualId);
                } else {
                    persist.showToast( qsTr("The source and replacement individuals cannot be the same!"), "", "asset:///images/toast/ic_duplicate_replace.png" );
                }
                
                navigationPane.pop();
            }
            
            function replace(ListItemData)
            {
                toReplaceId = ListItemData.id;
                definition.source = "IndividualPickerPage.qml";
                var ipp = definition.createObject();
                ipp.picked.connect(onActualPicked);
                
                navigationPane.push(ipp);
            }
            
            function getSelectedIds()
            {
                var all = listView.selectionList();
                var ids = [];
                
                for (var i = all.length-1; i >= 0; i--) {
                    ids.push( adm.data( all[i] ).id );
                }
                
                return ids;
            }
            
            multiSelectAction: MultiSelectActionItem {
                imageSource: "images/menu/ic_select_individuals.png"
            }
            
            onSelectionChanged: {
                var n = selectionList().length;
                multiSelectHandler.status = qsTr("%n individuals selected", "", n);
                setCompanions.enabled = n > 0;
            }
            
            multiSelectHandler.actions: [
                ActionItem
                {
                    id: setCompanions
                    imageSource: "images/menu/ic_set_companions.png"
                    title: qsTr("Set As Companions") + Retranslate.onLanguageChanged
                    
                    onTriggered: {
                        console.log("UserEvent: SetCompanions");
                        tafsirHelper.addCompanions( listView, listView.getSelectedIds() );
                        
                        var all = listView.selectionList();
                        
                        for (var i = all.length-1; i >= 0; i--)
                        {
                            var c = adm.data(all[i]);
                            c["companion_id"] = c.id;
                            adm.replace(all[i][0], c);
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
                        tafsirHelper.removeCompanions( listView, listView.getSelectedIds() );
                        
                        var all = listView.selectionList();
                        
                        for (var i = all.length-1; i >= 0; i--)
                        {
                            var c = adm.data(all[i]);
                            delete c["companion_id"];
                            adm.replace(all[i][0], c);
                        }
                    }
                }
            ]
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        id: sli
                        imageSource: ListItemData.companion_id ? "images/list/ic_companion.png" : "images/list/ic_individual.png"
                        description: ListItemData.prefix && ListItemData.prefix.length > 0 ? ListItemData.name : ""
                        status: ListItemData.kunya && ListItemData.kunya.length > 0 ? ListItemData.kunya : ""
                        title: ListItemData.prefix && ListItemData.prefix.length > 0 ? ListItemData.prefix : ListItemData.name
                        opacity: 0
                        
                        attachedObjects: [
                            FadeTransition {
                                id: fader
                                duration: Math.min( sli.ListItem.indexInSection*300, 750 );
                                easingCurve: StockCurve.SineOut
                                fromOpacity: 0
                                toOpacity: 1
                            }
                        ]
                        
                        ListItem.onInitializedChanged: {
                            if (initialized) {
                                fader.play();
                            }
                        }
                        
                        contextMenuHandler: ContextMenuHandler
                        {
                            onPopulating: {
                                if (!sli.ListItem.view.showContextMenu) {
                                    event.abort();
                                }
                            }
                        }
                        
                        contextActions: [
                            ActionSet
                            {
                                title: sli.title
                                subtitle: sli.description
                                
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
                                    imageSource: "images/menu/ic_edit_individual.png"
                                    title: qsTr("Edit") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: EditIndividual");
                                        sli.ListItem.view.edit(sli.ListItem.indexPath);
                                    }
                                }
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_replace_individual.png"
                                    title: qsTr("Replace") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: ReplaceIndividual");
                                        sli.ListItem.view.replace(ListItemData);
                                    }
                                }
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_delete_individual.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: DeleteIndividual");
                                        sli.ListItem.view.removeItem(ListItemData);
                                        sli.ListItem.view.dataModel.removeAt(sli.ListItem.indexPath[0]);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
            
            function onDataLoaded(id, data)
            {
                if (id == QueryId.SearchIndividuals || id == QueryId.FetchAllIndividuals)
                {
                    adm.clear();
                    adm.append(data);
                } else if (id == QueryId.EditIndividual) {
                    persist.showToast( qsTr("Successfully edited individual"), "", "asset:///images/dropdown/ic_save_individual.png" );
                } else if (id == QueryId.AddIndividual) {
                    persist.showToast( qsTr("Successfully added individual"), "", "asset:///images/dropdown/ic_save_individual.png" );
                } else if (id == QueryId.CopyIndividualsFromSource) {
                    persist.showToast( qsTr("Successfully ported individuals!"), "", "asset:///images/dropdown/ic_save_individual.png" );
                } else if (id == QueryId.RemoveIndividual) {
                    persist.showToast( qsTr("Successfully deleted individual!"), "", "asset:///images/menu/ic_delete_quote.png" );
                } else if (id == QueryId.ReplaceIndividual) {
                    persist.showToast( qsTr("Successfully replaced individual!"), "", "asset:///images/menu/ic_delete_quote.png" );
                } else if (id == QueryId.AddCompanions) {
                    persist.showToast( qsTr("Successfully added companions!"), "", "asset:///images/menu/ic_set_companions.png" );
                } else if (id == QueryId.RemoveCompanions) {
                    persist.showToast( qsTr("Successfully removed from companions!"), "", "asset:///images/menu/ic_remove_companions.png" );
                }
                
                busy.delegateActive = false;
            }
            
            onTriggered: {
                var d = dataModel.data(indexPath);
                console.log("UserEvent: IndividualPicked", d.name);
                picked(d.id);
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_individuals.png"
        }
    }
    
    attachedObjects: [
        Delegate
        {
            id: editDelegate
            property variant indexPath
            source: "EditIndividualSheet.qml"
            
            function onSaveClicked(indexPath, id, prefix, name, kunya, uri, bio, hidden, birth, death, female)
            {
                tafsirHelper.editIndividual(listView, id, prefix, name, kunya, uri, bio, hidden, birth, death, female);
                editDelegate.object.close();

                var obj = {'id': id, 'prefix': prefix, 'name': name, 'kunya': kunya, 'uri': uri, 'biography': bio, 'hidden': hidden, 'female': female};
                
                if (birth > 0) {
                    obj["birth"] = birth;
                }
                
                if (death > 0) {
                    obj["death"] = death;
                }
                
                adm.replace(indexPath[0], obj);
            }
            
            onObjectChanged: {
                if (object) {
                    object.data = adm.data(indexPath);
                    object.indexPath = indexPath;
                    object.saveClicked.connect(onSaveClicked);
                }
            }
        },
        
        Delegate
        {
            id: createDelegate
            source: "EditIndividualSheet.qml"
            
            function onSaveClicked(indexPath, id, prefix, name, kunya, uri, bio, hidden, birth, death, female)
            {
                tafsirHelper.createIndividual(listView, prefix, name, kunya, uri, bio, birth, death);
                createDelegate.object.close();
                
                var obj = {'id': id, 'prefix': prefix, 'name': name, 'kunya': kunya, 'uri': uri, 'biography': bio, 'hidden': hidden, 'female': female};
                
                if (birth > 0) {
                    obj["birth"] = birth;
                }
                
                if (death > 0) {
                    obj["death"] = death;
                }
                
                adm.insert(0, obj);
            }
            
            onObjectChanged: {
                if (object) {
                    object.saveClicked.connect(onSaveClicked);
                }
            }
        }
    ]
}