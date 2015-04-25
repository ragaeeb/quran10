import bb.cascades 1.0
import bb.system 1.0
import com.canadainc.data 1.0

Page
{
    id: bioPickerPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    function reload()
    {
        busy.delegateActive = true;
        tafsirHelper.fetchAllBios(listView);
    }
    
    function popToRoot()
    {
        while (navigationPane.top != bioPickerPage) {
            navigationPane.pop();
        }
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(bioPickerPage, listView, true);
        helper.textualChange.connect(reload);
        
        bioTypeDialog.appendItem( qsTr("Jarh") );
        bioTypeDialog.appendItem( qsTr("Biography"), true, true );
        bioTypeDialog.appendItem( qsTr("Tahdeel") );
    }
    
    actions: [
        ActionItem
        {
            id: addAction
            imageSource: "images/menu/ic_add_bio.png"
            title: qsTr("Add") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            function onBioSaved(id, author, heading, body, reference)
            {
                id = tafsirHelper.addBio(listView, body, reference, author, heading);
                popToRoot();
                
                var e = {'bio_id': id, 'author': author, 'reference': reference, 'body': body, 'heading': heading};
                adm.insert(e);
                
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
            }
            
            onTriggered: {
                console.log("UserEvent: AddBio");
                var page = global.createObject("CreateBioPage.qml");
                page.createBio.connect(onBioSaved);
                
                navigationPane.push(page);
            }
        }
    ]
    
    titleBar: TitleBar
    {
        id: tb
        title: qsTr("Biographies") + Retranslate.onLanguageChanged
        scrollBehavior: TitleBarScrollBehavior.NonSticky
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
            
            dataModel: GroupDataModel
            {
                id: adm
                sortingKeys: ["bio_id", "target"]
                grouping: ItemGrouping.ByFullValue
                sortedAscending: false
            }
            
            function onDataLoaded(id, data)
            {
                if (id == QueryId.FetchAllBios && data.length > 0) {
                    adm.insertList(data);
                } else if (id == QueryId.RemoveBio) {
                    persist.showToast( qsTr("Biography removed!"), "images/menu/ic_remove_bio.png" );
                } else if (id == QueryId.RemoveBioLink) {
                    persist.showToast( qsTr("Biography unlinked!"), "images/menu/ic_remove_bio.png" );
                } else if (id == QueryId.EditBio) {
                    persist.showToast( qsTr("Biography updated!"), "images/menu/ic_edit_bio.png" );
                } else if (id == QueryId.AddBio) {
                    persist.showToast( qsTr("Successfully added biography!"), "images/menu/ic_add_bio.png" );
                    reload();
                } else if (id == QueryId.AddBioLink) {
                    persist.showToast( qsTr("Biography linked!"), "images/menu/ic_add_bio.png" );
                    popToRoot();
                } else if (id == QueryId.SearchBio) {
                    adm.clear();
                    adm.insertList(data);
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
            
            function onPicked(individualId, name)
            {
                bioTypeDialog.target = individualId;
                bioTypeDialog.targetName = name;
                bioTypeDialog.show();
            }
            
            function addBioLink(ListItem)
            {
                editIndexPath = ListItem.indexPath;
                var c = global.createObject("IndividualPickerPage.qml");
                c.picked.connect(onPicked);

                navigationPane.push(c);
            }
            
            function onEditBio(bioId, author, heading, body, reference)
            {
                tafsirHelper.editBio(listView, bioId, body, reference, author, heading);

                var indexPath = [editIndexPath[0],0];
                var current = adm.data(indexPath);
                current["bio_id"] = bioId;
                current["heading"] = heading;
                current["body"] = body;
                current["reference"] = reference;
                adm.updateItem(indexPath, current);
                
                popToRoot();
            }
            
            function editBio(ListItem)
            {
                editIndexPath = ListItem.indexPath;

                var page = global.createObject("CreateBioPage.qml");
                page.createBio.connect(onEditBio);
                page.bioId = ListItem.data;
                
                navigationPane.push(page);
            }
            
            function removeBio(ListItem, ListItemData)
            {
                busy.delegateActive = true;
                tafsirHelper.removeBio(listView, ListItemData);
                adm.removeAt(ListItem.indexPath);
            }
            
            function removeBioLink(ListItem)
            {
                busy.delegateActive = true;
                tafsirHelper.removeBioLink(listView, ListItem.data.mention_id);
                adm.removeAt(ListItem.indexPath);
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    type: "header"
                    
                    Container
                    {
                        id: header
                        topPadding: 10
                        
                        Header
                        {
                            id: headerControl
                            
                            title: {
                                var d = global.getHeaderData(header.ListItem);
                                return d.heading ? d.heading : d.author ? d.author : d.bio_id;
                            }

                            subtitle: header.ListItem.view.dataModel.childCount(header.ListItem.indexPath)
                        }
                        
                        Label
                        {
                            id: headerLabel
                            content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                            text: global.getHeaderData(header.ListItem).body
                            multiline: true
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                        }
                        
                        contextActions: [
                            ActionSet
                            {
                                title: headerControl.title
                                subtitle: headerLabel.text
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_add_bio.png"
                                    title: qsTr("Add Link") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: AddLink");
                                        header.ListItem.view.addBioLink(header.ListItem);
                                    }
                                }
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_edit_bio.png"
                                    title: qsTr("Edit") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: EditBio");
                                        header.ListItem.view.editBio(header.ListItem);
                                    }
                                }
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_bio.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: DeleteBio");
                                        header.ListItem.view.removeBio(header.ListItem, ListItemData);
                                    }
                                }
                            }
                        ]
                    }
                },
                
                ListItemComponent
                {
                    type: "item"
                    
                    StandardListItem
                    {
                        id: rootItem
                        title: ListItemData.target ? ListItemData.target : qsTr("No links found...") + Retranslate.onLanguageChanged
                        imageSource: ListItemData.points > 0 ? "images/list/ic_like.png" : ListItemData.points < 0 ? "images/list/ic_dislike.png" : "images/list/ic_bio.png"
                        
                        contextMenuHandler: [
                            ContextMenuHandler {
                                onPopulating: {
                                    if (!ListItemData.target) {
                                        event.abort();
                                    }
                                }
                            }
                        ]
                        
                        contextActions: [
                            ActionSet
                            {
                                title: rootItem.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_bio.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: DeleteBioLink");
                                        rootItem.ListItem.view.removeBioLink(rootItem.ListItem);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
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
    
    attachedObjects: [
        SystemListDialog
        {
            id: bioTypeDialog
            property variant target
            property string targetName
            title: qsTr("Biography Type") + Retranslate.onLanguageChanged
            body: qsTr("Please select the type of biography this is:") + Retranslate.onLanguageChanged
            cancelButton.label: qsTr("Cancel")
            confirmButton.label: qsTr("OK") + Retranslate.onLanguageChanged
            
            onFinished: {
                if (value == SystemUiResult.ConfirmButtonSelection)
                {
                    var bioId = listView.dataModel.data(listView.editIndexPath);
                    var selectedIndex = selectedIndices[0];
                    var points;
                    
                    if (selectedIndex == 0) {
                        points = -1;
                    } else if (selectedIndex == 2) {
                        points = 1;
                    }
                    
                    var id = tafsirHelper.addBioLink(listView, bioId, target, points);
                    var e = {'bio_id': bioId, 'mention_id': id, 'points': points, 'target': targetName};
                    adm.insert(e);
                }
            }
        }
    ]
}