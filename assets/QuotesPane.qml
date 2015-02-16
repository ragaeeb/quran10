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
        helper.fetchAllQuotes(listView);
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(quotePickerPage, listView, true);
        reload();
    }
    
    Page
    {
        id: quotePickerPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        actions: [
            ActionItem
            {
                id: addAction
                imageSource: "images/menu/ic_add_quote.png"
                title: qsTr("Add") + Retranslate.onLanguageChanged
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                
                function onCreate(id, author, body, reference)
                {
                    helper.addQuote(listView, author, body, reference);
                    
                    while (navigationPane.top != quotePickerPage) {
                        navigationPane.pop();
                    }
                }
                
                onTriggered: {
                    definition.source = "CreateQuotePage.qml";
                    var page = definition.createObject();
                    page.createQuote.connect(onCreate);
                    
                    navigationPane.push(page);
                }
            }
        ]
        
        titleBar: TitleBar {
            title: qsTr("Quotes") + Retranslate.onLanguageChanged
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
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllQuotes && data.length > 0)
                    {
                        if ( adm.isEmpty() ) {
                            adm.append(data);
                        } else {
                            adm.insert(0, data[0]); // add the latest value to avoid refreshing entire list
                            listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                        }
                        
                        navigationPane.parent.unreadContentCount = data.length;
                    } else if (id == QueryId.RemoveQuote) {
                        persist.showToast( qsTr("Quote removed!"), "", "asset:///images/menu/ic_remove_suite.png" );
                    } else if (id == QueryId.EditQuote) {
                        persist.showToast( qsTr("Quote updated!"), "", "asset:///images/menu/ic_edit_suite.png" );
                    } else if (id == QueryId.AddQuote) {
                        persist.showToast( qsTr("Quote added!"), "", "asset:///images/menu/ic_add_quote.png" );
                        reload();
                    }
                    
                    busy.delegateActive = false;
                }
                
                function onEdit(id, author, body, reference)
                {
                    busy.delegateActive = true;
                    helper.editQuote(listView, id, author, body, reference);
                    
                    var current = dataModel.data(editIndexPath);
                    current["body"] = body;
                    current["reference"] = reference;
                    
                    dataModel.replace(editIndexPath[0], current);
                    
                    while (navigationPane.top != quotePickerPage) {
                        navigationPane.pop();
                    }
                }
                
                function openQuote(ListItemData)
                {
                    definition.source = "CreateQuotePage.qml";
                    var page = definition.createObject();
                    page.quoteId = ListItemData.id;
                    
                    navigationPane.push(page);
                    
                    return page;
                }
                
                function duplicateQuote(ListItemData)
                {
                    var page = openQuote(ListItemData);
                    page.showAuthorId = true;
                    page.createQuote.connect(addAction.onCreate);
                }
                
                function editItem(indexPath, ListItemData)
                {
                    editIndexPath = indexPath;
                    var page = openQuote(ListItemData);
                    page.createQuote.connect(onEdit);
                }
                
                function removeItem(ListItemData) {
                    busy.delegateActive = true;
                    helper.removeQuote(listView, ListItemData.id);
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        StandardListItem
                        {
                            id: rootItem
                            description: ListItemData.body
                            imageSource: "images/list/ic_quote.png"
                            title: ListItemData.author
                            
                            contextActions: [
                                ActionSet
                                {
                                    title: rootItem.title
                                    subtitle: rootItem.description
                                    
                                    ActionItem
                                    {
                                        imageSource: "images/menu/ic_copy_quote.png"
                                        title: qsTr("Duplicate") + Retranslate.onLanguageChanged
                                        
                                        onTriggered: {
                                            console.log("UserEvent: DuplicateQuote");
                                            rootItem.ListItem.view.duplicateQuote(ListItemData);
                                        }
                                    }
                                    
                                    ActionItem
                                    {
                                        imageSource: "images/menu/ic_edit_quote.png"
                                        title: qsTr("Edit") + Retranslate.onLanguageChanged
                                        
                                        onTriggered: {
                                            console.log("UserEvent: EditQuote");
                                            rootItem.ListItem.view.editItem(rootItem.ListItem.indexPath, ListItemData);
                                        }
                                    }
                                    
                                    DeleteActionItem
                                    {
                                        imageSource: "images/menu/ic_delete_quote.png"
                                        
                                        onTriggered: {
                                            console.log("UserEvent: DeleteQuoteTriggered");
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
                    console.log("UserEvent: AdminQuoteTriggered");
                    var d = dataModel.data(indexPath);
                    persist.showBlockingDialog(d.author, d.body, qsTr("OK"), "");
                }
            }
            
            ProgressControl
            {
                id: busy
                asset: "images/progress/loading_quotes.png"
            }
        }   
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}