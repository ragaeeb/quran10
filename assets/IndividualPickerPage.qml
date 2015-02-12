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
        }
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
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                function edit(indexPath)
                {
                    var d = dataModel.data(indexPath);
                    editDelegate.active = true;
                    editDelegate.object.data = d;
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
                                    delay: Math.min( sli.ListItem.indexInSection*150, 500 );
                                    duration: Math.min( sli.ListItem.indexInSection*300, 750 );
                                    easingCurve: StockCurve.BackOut
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
                    if (id == QueryId.SearchIndividuals)
                    {
                        adm.clear();
                        adm.append(data);
                        busy.delegateActive = false;
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
            source: "EditIndividualSheet.qml"
        }        
    ]
}