import bb.cascades 1.3
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    property alias searchField: tftk.textField
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    function reload()
    {
        busy.delegateActive = true;
        helper.fetchAllQuotes(listView);
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(quotePickerPage, listView, true);
        reload();
        helper.textualChange.connect(reload);
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
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.CreateNew
                    }
                ]
                
                function onCreate(id, author, body, reference, suiteId, uri)
                {
                    tafsirHelper.addQuote( listView, author, body, reference, suiteId, uri );
                    
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
        
        titleBar: TitleBar
        {
            kind: TitleBarKind.TextField
            kindProperties: TextFieldTitleBarKindProperties
            {
                id: tftk
                textField.hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
                textField.input.submitKey: SubmitKey.Search
                textField.input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                textField.input.onSubmitted: {
                    var query = searchField.text.trim();
                    
                    if (query.length == 0) {
                        adm.clear();
                        reload();
                    } else {
                        busy.delegateActive = true;
                        tafsirHelper.searchQuote(listView, searchColumn.selectedValue, query);
                    }
                }
                
                onCreationCompleted: {
                    textField.input["keyLayout"] = 7;
                }
            }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                ListView
                {
                    id: listView
                    property variant editIndexPath
                    scrollRole: ScrollRole.Main
                    
                    dataModel: ArrayDataModel {
                        id: adm
                    }
                    
                    leadingVisual: Container
                    {
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        
                        SegmentedControl
                        {
                            id: searchColumn
                            horizontalAlignment: HorizontalAlignment.Fill
                            
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
                                imageSource: "images/dropdown/search_quote_reference.png"
                                text: qsTr("Reference") + Retranslate.onLanguageChanged
                                value: "reference"
                            }
                            
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                        }
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
                            persist.showToast( qsTr("Quote removed!"), "images/menu/ic_delete_quote.png" );
                        } else if (id == QueryId.EditQuote) {
                            persist.showToast( qsTr("Quote updated!"), "images/menu/ic_edit_quote.png" );
                        } else if (id == QueryId.AddQuote) {
                            persist.showToast( qsTr("Quote added!"), "images/menu/ic_add_quote.png" );
                            reload();
                        } else if (id == QueryId.SearchQuote) {
                            adm.clear();
                            adm.append(data);
                        }
                        
                        busy.delegateActive = false;
                        listView.visible = !adm.isEmpty();
                        noElements.delegateActive = !listView.visible;
                    }
                    
                    function onEdit(id, author, body, reference, suiteId, uri)
                    {
                        busy.delegateActive = true;
                        tafsirHelper.editQuote(listView, id, author, body, reference, suiteId, uri);
                        
                        var current = dataModel.data(editIndexPath);
                        current["body"] = body;
                        current["reference"] = reference;
                        current["suite_id"] = suiteId;
                        current["uri"] = uri;
                        
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
                        page.createQuote.connect(addAction.onCreate);
                        page.titleBar.title = qsTr("New Quote");
                    }
                    
                    function editItem(indexPath, ListItemData)
                    {
                        editIndexPath = indexPath;
                        var page = openQuote(ListItemData);
                        page.createQuote.connect(onEdit);
                    }
                    
                    function removeItem(ListItemData) {
                        busy.delegateActive = true;
                        tafsirHelper.removeQuote(listView, ListItemData.id);
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
                                            imageSource: "images/menu/ic_edit_quote.png"
                                            title: qsTr("Edit") + Retranslate.onLanguageChanged
                                            
                                            onTriggered: {
                                                console.log("UserEvent: EditQuote");
                                                rootItem.ListItem.view.editItem(rootItem.ListItem.indexPath, ListItemData);
                                            }
                                        }
                                        
                                        ActionItem
                                        {
                                            imageSource: "images/menu/ic_copy.png"
                                            title: qsTr("Copy") + Retranslate.onLanguageChanged
                                            
                                            onTriggered: {
                                                console.log("UserEvent: CopyQuote");
                                                var body = "“%1” - %2 [%3]".arg(ListItemData.body).arg(ListItemData.author).arg(ListItemData.reference);
                                                persist.copyToClipboard(body);
                                            }
                                        }
                                        
                                        ActionItem
                                        {
                                            imageSource: "images/menu/ic_preview.png"
                                            title: qsTr("Preview") + Retranslate.onLanguageChanged
                                            
                                            onTriggered: {
                                                console.log("UserEvent: PreviewQuote");
                                                var body = "<html><i>“%1”</i>\n\n- <b>%2</b>\n\n[%3]</html>".arg( ListItemData.body.replace(/&/g,"&amp;") ).arg(ListItemData.author).arg( ListItemData.reference.replace(/&/g,"&amp;") );
                                                notification.init(body, "images/menu/ic_preview.png");
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
                        duplicateQuote(d);
                    }
                }
            }
            
            EmptyDelegate
            {
                id: noElements
                graphic: "images/placeholders/empty_suites.png"
                labelText: qsTr("No quotes matched your search criteria. Please try a different search term.") + Retranslate.onLanguageChanged
                
                onImageTapped: {
                    console.log("UserEvent: NoQuotesTapped");
                    searchField.requestFocus();
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