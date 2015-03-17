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
            imageSource: "images/menu/ic_copy.png"
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
    
    titleBar: TitleBar {
        title: qsTr("Search Individual") + Retranslate.onLanguageChanged
    }
    
    function performSearch()
    {
        var trimmed = searchField.text.trim();
        
        if (trimmed.length > 0)
        {
            busy.delegateActive = true;
            noElements.delegateActive = false;
            
            helper.searchIndividuals(listView, trimmed);
        } else {
            helper.fetchAllIndividuals(listView);
        }
    }
    
    onCreationCompleted: {
        helper.fetchFrequentIndividuals(listView);
    }
    
    Container
    {
        id: searchContainer
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
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
                }
            ]
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
                property bool showContextMenu
                scrollRole: ScrollRole.Main
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                function edit(indexPath)
                {
                    editDelegate.indexPath = indexPath;
                    editDelegate.active = true;
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        StandardListItem
                        {
                            id: sli
                            imageSource: "images/list/ic_individual.png"
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
                        busy.delegateActive = false;
                    } else if (id == QueryId.EditIndividual) {
                        persist.showToast( qsTr("Successfully edited individual"), "", "asset:///images/dropdown/ic_save_individual.png" );
                    } else if (id == QueryId.AddIndividual) {
                        persist.showToast( qsTr("Successfully added individual"), "", "asset:///images/dropdown/ic_save_individual.png" );
                    } else if (id == QueryId.CopyIndividualsFromSource) {
                        persist.showToast( qsTr("Successfully ported individuals!"), "", "asset:///images/dropdown/ic_save_individual.png" );
                    }
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
    }
    
    attachedObjects: [
        Delegate
        {
            id: editDelegate
            property variant indexPath
            source: "EditIndividualSheet.qml"
            
            function onSaveClicked(indexPath, id, prefix, name, kunya, uri, bio, hidden, birth, death)
            {
                helper.editIndividual(listView, id, prefix, name, kunya, uri, bio, hidden, birth, death);
                editDelegate.object.close();

                var obj = {'id': id, 'prefix': prefix, 'name': name, 'kunya': kunya, 'uri': uri, 'biography': bio, 'hidden': hidden};
                
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
            
            function onSaveClicked(indexPath, id, prefix, name, kunya, uri, bio, hidden, birth, death)
            {
                helper.createIndividual(listView, prefix, name, kunya, uri, bio, birth, death);
                createDelegate.object.close();
                
                var obj = {'id': id, 'prefix': prefix, 'name': name, 'kunya': kunya, 'uri': uri, 'biography': bio, 'hidden': hidden};
                
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