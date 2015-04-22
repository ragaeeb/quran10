import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    function reload()
    {
        busy.delegateActive = true;
        helper.fetchAllBios(listView);
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(bioPickerPage, listView, true);
        reload();
        helper.textualChange.connect(reload);
    }
    
    Page
    {
        id: bioPickerPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        actions: [
            ActionItem
            {
                id: addAction
                imageSource: "images/menu/ic_add_quote.png"
                title: qsTr("Add") + Retranslate.onLanguageChanged
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.CreateNew
                    }
                ]
                
                function onCreate(id, author, body, reference)
                {
                    tafsirHelper.addBio(listView, author, body, reference);
                    
                    while (navigationPane.top != bioPickerPage) {
                        navigationPane.pop();
                    }
                }
                
                onTriggered: {
                    definition.source = "CreateBioPage.qml";
                    var page = definition.createObject();
                    page.createBio.connect(onCreate);
                    
                    navigationPane.push(page);
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
                        hintText: qsTr("Enter biography to search...") + Retranslate.onLanguageChanged
                        horizontalAlignment: HorizontalAlignment.Fill
                        bottomMargin: 0
                        
                        input {
                            submitKey: SubmitKey.Search
                            flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                            submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                            
                            onSubmitted: {
                                var query = searchField.text.trim();
                                
                                if (query.length == 0) {
                                    adm.clear();
                                    reload();
                                } else {
                                    busy.delegateActive = true;
                                    tafsirHelper.searchBio(listView, searchColumn.selectedValue, query);
                                }
                            }
                        }
                        
                        onCreationCompleted: {
                            input["keyLayout"] = 7;
                        }
                    }
                }
                
                expandableArea.onExpandedChanged: {
                    searchField.requestFocus();
                }
                
                expandableArea.content: Container
                {
                    DropDown
                    {
                        id: searchColumn
                        title: qsTr("Field") + Retranslate.onLanguageChanged
                        
                        Option {
                            description: qsTr("Search author field") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/search_author.png"
                            text: qsTr("Author") + Retranslate.onLanguageChanged
                            value: "author"
                        }
                        
                        Option {
                            description: qsTr("Search quote text") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/search_quote_body.png"
                            text: qsTr("Body") + Retranslate.onLanguageChanged
                            value: "body"
                            selected: true
                        }
                        
                        Option {
                            description: qsTr("Search reference field") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/search_reference.png"
                            text: qsTr("Reference") + Retranslate.onLanguageChanged
                            value: "reference"
                        }
                    }
                }
            }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}
            
            ListView
            {
                id: listView
                property variant editIndexPath
                scrollRole: ScrollRole.Main
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllBios && data.length > 0)
                    {
                        if ( adm.isEmpty() ) {
                            adm.append(data);
                        } else {
                            adm.insert(0, data[0]); // add the latest value to avoid refreshing entire list
                            listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                        }
                        
                        navigationPane.parent.unreadContentCount = data.length;
                    } else if (id == QueryId.RemoveBio) {
                        persist.showToast( qsTr("Biography removed!"), "images/menu/ic_remove_bio.png" );
                    } else if (id == QueryId.EditBio) {
                        persist.showToast( qsTr("Biography updated!"), "images/menu/ic_edit_bio.png" );
                    } else if (id == QueryId.AddBio) {
                        persist.showToast( qsTr("Biography added!"), "images/menu/ic_add_bio.png" );
                        reload();
                    } else if (id == QueryId.SearchBio) {
                        adm.clear();
                        adm.append(data);
                    }
                    
                    busy.delegateActive = false;
                    listView.visible = !adm.isEmpty();
                    noElements.delegateActive = !listView.visible;
                }
                
                function onEdit(id, author, body, reference)
                {
                    busy.delegateActive = true;
                    tafsirHelper.editBio(listView, id, author, body, reference);
                    
                    var current = dataModel.data(editIndexPath);
                    current["body"] = body;
                    current["reference"] = reference;
                    
                    dataModel.replace(editIndexPath[0], current);
                    
                    while (navigationPane.top != bioPickerPage) {
                        navigationPane.pop();
                    }
                }
                
                function openBio(ListItemData)
                {
                    definition.source = "CreateBioPage.qml";
                    var page = definition.createObject();
                    page.bioId = ListItemData.id;
                    
                    navigationPane.push(page);
                    
                    return page;
                }
                
                function duplicateBio(ListItemData)
                {
                    var page = openBio(ListItemData);
                    page.createBio.connect(addAction.onCreate);
                    page.titleBar.title = qsTr("New Bio");
                }
                
                function editItem(indexPath, ListItemData)
                {
                    editIndexPath = indexPath;
                    var page = openBio(ListItemData);
                    page.createBio.connect(onEdit);
                }
                
                function removeItem(ListItemData) {
                    busy.delegateActive = true;
                    tafsirHelper.removeBio(listView, ListItemData.id);
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        StandardListItem
                        {
                            id: rootItem
                            description: ListItemData.body
                            imageSource: "images/list/ic_bio.png"
                            title: ListItemData.author
                            
                            contextActions: [
                                ActionSet
                                {
                                    title: rootItem.title
                                    subtitle: rootItem.description
                                    
                                    ActionItem
                                    {
                                        imageSource: "images/menu/ic_edit_bio.png"
                                        title: qsTr("Edit") + Retranslate.onLanguageChanged
                                        
                                        onTriggered: {
                                            console.log("UserEvent: EditBio");
                                            rootItem.ListItem.view.editItem(rootItem.ListItem.indexPath, ListItemData);
                                        }
                                    }
                                    
                                    DeleteActionItem
                                    {
                                        imageSource: "images/menu/ic_remove_bio.png"
                                        
                                        onTriggered: {
                                            console.log("UserEvent: DeleteBio");
                                            rootItem.ListItem.view.removeItem(ListItemData);
                                            rootItem.ListItem.view.dataModel.removeAt(rootItem.ListItem.indexPath[0]);
                                        }
                                    }
                                }
                            ]
                        }
                    }
                ]
                
                onTriggered: {
                    console.log("UserEvent: AdminBioTriggered");
                    var d = dataModel.data(indexPath);
                    duplicateBio(d);
                }
            }
            
            EmptyDelegate
            {
                id: noElements
                graphic: "images/placeholders/empty_bios.png"
                labelText: qsTr("No biographies matched your search criteria. Please try a different search term.") + Retranslate.onLanguageChanged
                
                onImageTapped: {
                    console.log("UserEvent: NoBiosTapped");
                    searchField.requestFocus();
                }
            }
            
            ProgressControl
            {
                id: busy
                asset: "images/progress/loading_bios.png"
            }
        }   
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}