import bb.cascades 1.2
import com.canadainc.data 1.0

Page
{
    id: individualPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal picked(variant cityId, string name)
    
    actions: [
        ActionItem {
            id: searchAction
            imageSource: "images/menu/ic_search_location.png"
            title: qsTr("Search") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: SearchLocationTriggered");
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
        title: qsTr("Select Location") + Retranslate.onLanguageChanged
    }
    
    function performSearch()
    {
        var trimmed = searchField.text.trim();
        
        if (trimmed.length > 0)
        {
            busy.delegateActive = true;
            noElements.delegateActive = false;
            
            tafsirHelper.fetchAllLocations(listView, trimmed);
        } else {
            tafsirHelper.fetchAllLocations(listView);
        }
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
            graphic: "images/placeholders/empty_locations.png"
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
                        easingCurve: StockCurve.ExponentialOut
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
                
                function itemType(data, indexPath)
                {
                    if (data.formatted_address) {
                        return "address";
                    } else {
                        return "city";
                    }
                }
                
                function editLocation(ListItem)
                {
                    var element = ListItem.data;
                    var currentCity = ListItem.data.city;
                    currentCity = persist.showBlockingPrompt( qsTr("Enter city name"), qsTr("Please enter the new name of the city:"), currentCity, qsTr("Enter city name (ie: Damascus)"), 40, true, qsTr("Save"), qsTr("Cancel") ).trim();
                    
                    if (currentCity.length > 0)
                    {
                        element["city"] = currentCity;
                        
                        tafsirHelper.editLocation(listView, element.id, currentCity);
                        adm.replace(ListItem.indexPath[0], element);
                    }
                }
                
                function deleteCity(ListItem)
                {
                    tafsirHelper.removeLocation(listView, ListItem.data.id);
                    adm.removeAt(ListItem.indexPath[0]);
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        type: "city"
                        
                        StandardListItem
                        {
                            id: sli
                            imageSource: "images/list/ic_location.png"
                            status: "(%1,%2)".arg(ListItemData.latitude).arg(ListItemData.longitude)
                            title: ListItemData.city
                            
                            contextActions: [
                                ActionSet
                                {
                                    title: sli.title
                                    subtitle: sli.description
                                    
                                    ActionItem
                                    {
                                        imageSource: "images/menu/ic_edit_location.png"
                                        title: qsTr("Edit") + Retranslate.onLanguageChanged
                                        
                                        onTriggered: {
                                            console.log("UserEvent: EditLocation");
                                            sli.ListItem.view.editLocation(sli.ListItem);
                                        }
                                    }
                                    
                                    DeleteActionItem
                                    {
                                        imageSource: "images/menu/ic_remove_location.png"
                                        
                                        onTriggered: {
                                            console.log("UserEvent: RemoveCity");
                                            sli.ListItem.view.deleteCity(sli.ListItem);
                                        }
                                    }
                                }
                            ]
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "address"
                        
                        StandardListItem
                        {
                            id: address
                            imageSource: "images/list/ic_geo_result.png"
                            status: "(%1,%2)".arg(ListItemData.geometry.location.lat).arg(ListItemData.geometry.location.lng)
                            title: ListItemData.formatted_address
                        }
                    }
                ]
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllLocations)
                    {
                        adm.clear();
                        adm.append(data);
                        
                        busy.delegateActive = false;
                        noElements.delegateActive = adm.isEmpty();
                        listView.visible = !adm.isEmpty();
                    } else if (id == QueryId.AddLocation) {
                        persist.showToast( qsTr("Location added!"), "asset:///images/toast/ic_location_added.png" );
                        performSearch();
                    } else if (id == QueryId.RemoveLocation) {
                        persist.showToast( qsTr("Location removed!"), "asset:///images/toast/ic_remove_location.png" );
                    } else if (id == QueryId.EditLocation) {
                        persist.showToast( qsTr("Location updated!"), "asset:///images/menu/ic_edit_location.png" );
                    }
                }
                
                onTriggered: {
                    var d = dataModel.data(indexPath);
                    console.log("UserEvent: CityPicked");
                    
                    if (d.formatted_address)
                    {
                        var parts = d.address_components;
                        var city = "";
                        var latitude = d.geometry.location.lat;
                        var longitude = d.geometry.location.lng;
                        
                        for (var i = parts.length-1; i >= 0; i--)
                        {
                            var types = parts[i].types;
                            
                            if ( types.indexOf("locality") != -1 ) {
                                city = parts[i].long_name;
                            }
                        }
                        
                        if (city.length > 0) {
                            tafsirHelper.addLocation(listView, city, latitude, longitude);
                            searchField.text = city;
                        } else {
                            persist.showToast( qsTr("Could not find city metadata."), "asset:///images/toast/no_geo_found.png" );
                        }
                    } else {
                        picked(d.id, d.city);
                    }
                }
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_individuals.png"
        }
    }
    
    function onLocationsFound(result)
    {
        if (result.status == "OK")
        {
            adm.clear();
            adm.append(result.results);
        } else {
            persist.showToast( qsTr("Could not fetch geolocation results."), "asset:///images/toast/no_geo_found.png" );
        }
    }
    
    onCreationCompleted: {
        app.locationsFound.connect(onLocationsFound);
    }
}