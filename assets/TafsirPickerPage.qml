import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: tafsirPickerPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal tafsirPicked(variant data)
    property alias searchField: tftk.textField
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(tafsirPickerPage, listView, true);
        helper.textualChange.connect(clearAndReload);
    }
    
    function cleanUp() {
        helper.textualChange.disconnect(clearAndReload);
    }
    
    function clearAndReload()
    {
        adm.clear();
        reload();
    }
    
    function reload()
    {
        busy.delegateActive = true;
        helper.fetchAllTafsir(listView);
    }
    
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
                var query = textField.text.trim();
                
                if (query.length == 0) {
                    adm.clear();
                    reload();
                } else {
                    busy.delegateActive = true;
                    tafsirHelper.searchTafsir(listView, searchColumn.selectedValue, query);
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
        
        ListView
        {
            id: listView
            property variant editIndexPath
            scrollRole: ScrollRole.Main
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            leadingVisual: DropDown
            {
                id: searchColumn
                horizontalAlignment: HorizontalAlignment.Fill
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
                    text: qsTr("Reference") + Retranslate.onLanguageChanged
                    value: "reference"
                }
                Option {
                    description: qsTr("Search translator field") + Retranslate.onLanguageChanged
                    imageSource: "images/dropdown/search_translator.png"
                    text: qsTr("Translator") + Retranslate.onLanguageChanged
                    value: "translator"
                }                    
                Option {
                    description: qsTr("Search title field") + Retranslate.onLanguageChanged
                    imageSource: "images/dropdown/search_title.png"
                    selected: true
                    text: qsTr("Title") + Retranslate.onLanguageChanged
                    value: "title"
                }
            }
            
            function onEdit(id, author, translator, explainer, title, description, reference)
            {
                busy.delegateActive = true;
                tafsirHelper.editTafsir(listView, id, author, translator, explainer, title, description, reference);
                
                var current = dataModel.data(editIndexPath);
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
                tafsirHelper.removeTafsir(listView, ListItemData.id);
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        id: rootItem
                        description: ListItemData.author ? ListItemData.author : qsTr("Unknown") + Retranslate.onLanguageChanged
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
                    persist.showToast( qsTr("Tafsir removed!"), "images/menu/ic_remove_suite.png" );
                } else if (id == QueryId.EditTafsir) {
                    persist.showToast( qsTr("Tafsir updated!"), "images/menu/ic_edit_suite.png" );
                } else if (id == QueryId.SearchTafsir) {
                    adm.clear();
                    adm.append(data);
                }
                
                busy.delegateActive = false;
                listView.visible = !adm.isEmpty();
                noElements.delegateActive = !listView.visible;
            }
            
            onCreationCompleted: {
                reload();
            }
        }
        
        EmptyDelegate
        {
            id: noElements
            graphic: "images/placeholders/empty_suites.png"
            labelText: qsTr("No suites matched your search criteria. Please try a different search term.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                console.log("UserEvent: NoSuitesTapped");
                searchField.requestFocus();
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_suites.png"
        }
    }   
}