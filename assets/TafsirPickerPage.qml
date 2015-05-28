import QtQuick 1.0
import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: tafsirPickerPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal tafsirPicked(variant data)
    property alias searchField: tftk.textField
    property alias autoFocus: focuser.running
    property alias suiteList: listView
    property alias filter: searchColumn.selectedValue
    property alias busyControl: busy.delegateActive
    property bool allowMultiple: false
    
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
    
    function popToRoot()
    {
        while (navigationPane.top != tafsirPickerPage) {
            navigationPane.pop();
        }
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
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            DropDown
            {
                id: searchColumn
                horizontalAlignment: HorizontalAlignment.Fill
                title: qsTr("Field") + Retranslate.onLanguageChanged
                bottomMargin: 0
                
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
            
            ListView
            {
                id: listView
                property variant editIndexPath
                property variant destMergeId
                scrollRole: ScrollRole.Main

                multiSelectAction: MultiSelectActionItem {
                    enabled: allowMultiple                    
                }
                
                onSelectionChanged: {
                    var n = selectionList().length;
                    multiSelectHandler.status = qsTr("%n suites selected", "", n);
                    selectMulti.enabled = n > 0;
                }
                
                multiSelectHandler.actions: [
                    ActionItem
                    {
                        id: selectMulti
                        enabled: false
                        imageSource: "images/menu/ic_select_more_chapters.png"
                        title: qsTr("Select") + Retranslate.onLanguageChanged
                        
                        onTriggered: {
                            console.log("UserEvent: SelectMultipleTafsir");
                            
                            var all = listView.selectionList();
                            
                            for (var i = all.length-1; i >= 0; i--) {
                                all[i] = adm.data(all[i]);
                            }
                            
                            tafsirPicked(all);
                        }
                    }
                ]
                
                dataModel: ArrayDataModel {
                    id: adm
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
                    
                    popToRoot();
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
                
                function onActualPicked(suitesToMerge)
                {
                    var cleaned = [];
                    
                    for (var i = suitesToMerge.length-1; i >= 0; i--)
                    {
                        var current = suitesToMerge[i].id;
                        
                        if (current != destMergeId) {
                            cleaned.push(current);
                        }
                    }
                    
                    if (cleaned.length > 0)
                    {
                        busy.delegateActive = true;
                        tafsirHelper.mergeSuites(listView, cleaned, destMergeId);
                    } else {
                        persist.showToast( qsTr("The source and replacement suites cannot be the same!"), "images/toast/ic_duplicate_replace.png" );
                    }
                    
                    popToRoot();
                }
                
                function merge(ListItemData)
                {
                    destMergeId = ListItemData.id;
                    definition.source = "TafsirPickerPage.qml";
                    var ipp = definition.createObject();
                    ipp.allowMultiple = true;
                    ipp.tafsirPicked.connect(onActualPicked);
                    
                    navigationPane.push(ipp);
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
                            status: ListItemData.c ? ListItemData.c : undefined
                            
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
                                    
                                    ActionItem
                                    {
                                        imageSource: "images/menu/ic_replace_individual.png"
                                        title: qsTr("Merge") + Retranslate.onLanguageChanged
                                        
                                        onTriggered: {
                                            console.log("UserEvent: MergeSuite");
                                            rootItem.ListItem.view.merge(ListItemData);
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
                    if (allowMultiple)
                    {
                        multiSelectHandler.active = true;
                        toggleSelection(indexPath);
                    } else {
                        console.log("UserEvent: AdminTafsirTriggered");
                        tafsirPicked( [dataModel.data(indexPath)] );
                    }
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
                    } else if (id == QueryId.SearchTafsir || id == QueryId.FindDuplicates) {
                        adm.clear();
                        adm.append(data);
                    } else if (id == QueryId.ReplaceSuite) {
                        persist.showToast( qsTr("Successfully merged suite!"), "images/menu/ic_replace_individual.png" );
                        clearAndReload();
                    }
                    
                    busy.delegateActive = false;
                    listView.visible = !adm.isEmpty();
                    noElements.delegateActive = !listView.visible;
                }
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
    
    attachedObjects: [
        Timer {
            id: focuser
            interval: 250
            repeat: false
            running: false
            
            onTriggered: {
                tftk.textField.requestFocus();
            }
        }
    ]   
}