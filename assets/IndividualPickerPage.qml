import bb.cascades 1.2
import com.canadainc.data 1.0

Page
{
    id: individualPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property alias pickerList: listView
    property alias busyControl: busy
    property alias model: adm
    property alias allowEditing: listView.showContextMenu
    signal picked(variant individualId, string name)
    signal contentLoaded(int size)
    
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
        }
    ]
    
    titleBar: TitleBar {
        title: qsTr("Select Individual") + Retranslate.onLanguageChanged
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
        helper.textualChange.connect(performSearch);
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
        
        Container
        {
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
                        
                        onEnded: {
                            deviceUtils.attachTopBottomKeys(individualPage, listView);
                        }
                    }
                ]
            }
            
            ListView
            {
                id: listView
                property alias pickerPage: individualPage
                property bool showContextMenu: false
                scrollRole: ScrollRole.Main
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        IndividualListItem {
                            id: sli
                        }
                    }
                ]
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.SearchIndividuals || id == QueryId.FetchAllIndividuals)
                    {
                        adm.clear();
                        adm.append(data);
                        
                        contentLoaded(data.length);
                        busy.delegateActive = false;
                        noElements.delegateActive = adm.isEmpty();
                        listView.visible = !adm.isEmpty();
                    }
                }
                
                onTriggered: {
                    var d = dataModel.data(indexPath);
                    console.log("UserEvent: IndividualPicked", d.name);
                    picked(d.id, d.name);
                }
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_individuals.png"
        }
    }
}