import QtQuick 1.0
import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: individualPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property alias pickerList: listView
    property alias busyControl: busy
    property alias model: adm
    property alias allowEditing: listView.showContextMenu
    property alias searchField: tftk.textField
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
                performSearch();
            }
            
            onCreationCompleted: {
                textField.input["keyLayout"] = 7;
            }
        }
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
        deviceUtils.attachTopBottomKeys(individualPage, listView);
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
            property alias pickerPage: individualPage
            property bool showContextMenu: false
            scrollRole: ScrollRole.Main
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        id: sli
                        imageSource: ListItemData.is_companion ? "images/list/ic_companion.png" : "images/list/ic_individual.png"
                        title: ListItemData.name
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
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_individuals.png"
        }
    }
    
    attachedObjects: [
        Timer {
            interval: 250
            repeat: false
            running: true
            
            onTriggered: {
                tftk.textField.requestFocus();
            }
        }
    ]
}