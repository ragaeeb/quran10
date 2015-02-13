import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: tafsirPickerPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal tafsirPicked(variant data)
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(tafsirPickerPage, listView, true);
    }
    
    function reload()
    {
        busy.delegateActive = true;
        helper.fetchAllTafsir(listView);
    }
    
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
                        flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                        submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                        
                        onSubmitted: {
                            var query = searchField.text.trim();
                            
                            if (query.length == 0) {
                                adm.clear();
                                reload();
                            } else {
                                busy.delegateActive = true;
                                helper.searchTafsir(listView, searchColumn.selectedValue, query);
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
                        description: qsTr("Search tafsir body") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/search_body.png"
                        text: qsTr("Body") + Retranslate.onLanguageChanged
                        value: "body"
                    }
                    
                    Option {
                        description: qsTr("Search reference field") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/search_reference.png"
                        selected: true
                        text: qsTr("Reference") + Retranslate.onLanguageChanged
                        value: "reference"
                    }
                    
                    Option {
                        description: qsTr("Search title field") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/search_title.png"
                        selected: true
                        text: qsTr("Title") + Retranslate.onLanguageChanged
                        value: "title"
                    }
                    
                    Option {
                        description: qsTr("Search translator field") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/search_translator.png"
                        text: qsTr("Translator") + Retranslate.onLanguageChanged
                        value: "translator"
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
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            function onEdit(id, author, translator, explainer, title, description, reference)
            {
                busy.delegateActive = true;
                helper.editTafsir(listView, id, author, translator, explainer, title, description, reference);
                
                var current = dataModel.data(editIndexPath);
                current["author"] = author;
                current["explainer"] = explainer;
                current["title"] = title;
                current["description"] = description;
                current["reference"] = reference;
                
                dataModel.replace(editIndexPath[0], current);
                
                while (navigationPane.top != tafsirPickerPage) {
                    navigationPane.pop();
                }
            }
            
            function editItem(indexPath, ListItemData)
            {
                editIndexPath = indexPath;
                
                definition.source = "CreateTafsirPage.qml";
                var page = definition.createObject();
                page.suiteId = ListItemData.id;
                page.createTafsir.connect(onEdit);
                
                navigationPane.push(page);
            }
            
            function removeItem(ListItemData) {
                busy.delegateActive = true;
                helper.removeTafsir(listView, ListItemData.id);
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        id: rootItem
                        description: ListItemData.author
                        imageSource: "images/list/ic_tafsir.png"
                        title: ListItemData.title
                        
                        contextActions: [
                            ActionSet
                            {
                                title: rootItem.title
                                subtitle: rootItem.description
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_edit_suite.png"
                                    title: qsTr("Edit") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: EditTafsirTriggered");
                                        rootItem.ListItem.view.editItem(rootItem.ListItem.indexPath, ListItemData);
                                    }
                                }
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_suite.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: AdminDeleteTafsirTriggered");
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
                console.log("UserEvent: AdminTafsirTriggered");
                tafsirPicked( dataModel.data(indexPath) );
            }
            
            function onDataLoaded(id, data)
            {
                if (id == QueryId.FetchAllTafsir && data.length > 0)
                {
                    if ( adm.isEmpty() ) {
                        adm.append(data);
                    } else {
                        adm.insert(0, data[0]); // add the latest value to avoid refreshing entire list
                        listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                    }
                    
                    navigationPane.parent.unreadContentCount = data.length;
                } else if (id == QueryId.RemoveTafsir) {
                    persist.showToast( qsTr("Tafsir removed!"), "", "asset:///images/menu/ic_remove_suite.png" );
                } else if (id == QueryId.EditTafsir) {
                    persist.showToast( qsTr("Tafsir updated!"), "", "asset:///images/menu/ic_edit_suite.png" );
                } else if (id == QueryId.SearchTafsir) {
                    adm.clear();
                    adm.append(data);
                }
                
                busy.delegateActive = false;
            }
            
            onCreationCompleted: {
                reload();
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_suites.png"
        }
    }   
}