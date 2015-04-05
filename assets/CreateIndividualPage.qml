import bb.cascades 1.3
import bb.system 1.2
import com.canadainc.data 1.0

Page
{
    id: createRijaal
    property variant individualId
    signal createIndividual(variant id, string prefix, string name, string kunya, string displayName, bool hidden, int birth, int death, bool female, int location)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onIndividualIdChanged: {
        tafsirHelper.fetchIndividualData(createRijaal, individualId);
        tafsirHelper.fetchAllWebsites(createRijaal, individualId);
    }
    
    actions: [
        ActionItem
        {
            id: addSite
            imageSource: "images/menu/ic_add_site.png"
            title: qsTr("Add Website") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: NewSite");
                var uri = persist.showBlockingPrompt( qsTr("Enter url"), qsTr("Please enter the website address for this individual:"), "", qsTr("Enter url (ie: http://mtws.com)"), 100, false, qsTr("Save"), qsTr("Cancel"), SystemUiInputMode.Url );
                tafsirHelper.addWebsite(createRijaal, individualId, uri);
            }
        },
        
        ActionItem
        {
            id: validateLocation
            imageSource: "images/list/ic_geo_search.png"
            title: qsTr("Validate Location") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Edit
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: ValidateLocation");
                location.validator.validate();
            }
        }
    ]
    
    function onDataLoaded(id, results)
    {
        if (id == QueryId.FetchIndividualData && results.length > 0)
        {
            var data = results[0];
            
            hidden.checked = data.hidden == 1;
            female.checked = data.female == 1;
            titleBar.title = name.text = data.name;
            
            if (data.prefix) {
                prefix.text = data.prefix;
            }
            
            if (data.kunya) {
                kunya.text = data.kunya;
            }
            
            if (data.birth) {
                birth.text = data.birth;
            }
            
            if (data.death) {
                death.text = data.death;
            }
            
            if (data.displayName) {
                displayName.text = data.displayName;
            }
            
            if (data.location) {
                location.text = data.location.toString();
            }
        } else if (id == QueryId.FetchAllWebsites) {
            sites.count = results.length;
            results = offloader.decorateWebsites(results);
            adm.clear();
            adm.append(results);
        } else if (id == QueryId.RemoveWebsite || id == QueryId.AddWebsite) {
            tafsirHelper.fetchAllWebsites(createRijaal, individualId);
        }
    }
    
    titleBar: TitleBar
    {
        title: qsTr("New Individual") + Retranslate.onLanguageChanged
        
        acceptAction: ActionItem
        {
            id: saveAction
            imageSource: "images/dropdown/ic_save_individual.png"
            title: qsTr("Save") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: SaveIndividual");
                
                name.validator.validate();
                location.validator.validate();
                
                if (name.validator.valid && location.validator.valid) {
                    createIndividual(individualId, prefix.text.trim(), name.text.trim(), kunya.text.trim(), displayName.text.trim(), hidden.checked, parseInt( birth.text.trim() ), parseInt( death.text.trim() ), female.checked, parseInt( location.text.trim() ) );
                } else if (!location.validator.valid) {
                    persist.showToast( qsTr("Invalid location specified!"), "", "asset:///images/toast/incomplete_field.png" );
                } else {
                    persist.showToast( qsTr("Invalid name!"), "", "asset:///images/toast/incomplete_field.png" );
                }
            }
        }
    }

    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        ScrollView
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container
            {
                topPadding: 10
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                Container
                {
                    leftPadding: 10; rightPadding: 10
                    
                    CheckBox {
                        id: hidden
                        text: qsTr("Hidden") + Retranslate.onLanguageChanged
                    }
                    
                    CheckBox {
                        id: female
                        text: qsTr("Female") + Retranslate.onLanguageChanged
                    }
                }
                
                TextField
                {
                    id: prefix
                    hintText: qsTr("Prefix (ie: al-Hafidh, Shaykh)") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                    
                    gestureHandlers: [
                        DoubleTapHandler {
                            onDoubleTapped: {
                                console.log("UserEvent: PrefixDoubleTapped");
                                prefix.text = textUtils.toTitleCase( persist.getClipboardText() );
                            }
                        }
                    ]
                }
                
                TextField
                {
                    id: name
                    hintText: qsTr("Name...") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                    
                    validator: Validator
                    {
                        errorMessage: qsTr("Invalid name") + Retranslate.onLanguageChanged
                        mode: ValidationMode.FocusLost
                        
                        onValidate: { 
                            valid = name.text.trim().length > 3;
                        }
                    }
                    
                    gestureHandlers: [
                        DoubleTapHandler {
                            onDoubleTapped: {
                                console.log("UserEvent: IndividualNameDoubleTapped");
                                name.text = textUtils.toTitleCase( persist.getClipboardText() );
                            }
                        }
                    ]
                }
                
                TextField
                {
                    id: kunya
                    hintText: qsTr("Kunya...") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                    
                    gestureHandlers: [
                        DoubleTapHandler {
                            onDoubleTapped: {
                                console.log("UserEvent: IndividualKunyaDoubleTapped");
                                kunya.text = textUtils.toTitleCase( persist.getClipboardText() );
                            }
                        }
                    ]
                }
                
                TextField
                {
                    id: birth
                    hintText: qsTr("Birth (AH)...") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                    inputMode: TextFieldInputMode.NumbersAndPunctuation
                    maximumLength: 4
                    
                    gestureHandlers: [
                        DoubleTapHandler {
                            onDoubleTapped: {
                                console.log("UserEvent: BirthDoubleTapped");
                                birth.text = persist.getClipboardText();
                            }
                        }
                    ]
                }
                
                TextField
                {
                    id: death
                    hintText: qsTr("Death (AH)...") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                    inputMode: TextFieldInputMode.NumbersAndPunctuation
                    maximumLength: 4
                    
                    gestureHandlers: [
                        DoubleTapHandler {
                            onDoubleTapped: {
                                console.log("UserEvent: DeathDoubleTapped");
                                death.text = persist.getClipboardText();
                            }
                        }
                    ]
                }
                
                TextField
                {
                    id: displayName
                    hintText: qsTr("Display Name...") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                    
                    gestureHandlers: [
                        DoubleTapHandler {
                            onDoubleTapped: {
                                console.log("UserEvent: DisplayNameDoubleTapped");
                                name.text = textUtils.toTitleCase( persist.getClipboardText() );
                            }
                        }
                    ]
                }
                
                TextField
                {
                    id: location
                    hintText: qsTr("City of birth...") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                    
                    validator: Validator
                    {
                        errorMessage: qsTr("No locations found...") + Retranslate.onLanguageChanged;
                        mode: ValidationMode.Custom

                        onValidate: {
                            var trimmed = location.text.trim();
                            
                            if (trimmed.length == 0) {
                                valid = true;
                            } else {
                                if ( trimmed.match("\\d+") ) {
                                    valid = true;
                                } else {
                                    createLocationPicker();
                                    app.geoLookup(trimmed);
                                }
                            }
                        }
                    }
                    
                    gestureHandlers: [
                        DoubleTapHandler
                        {
                            id: dth
                            
                            function onPicked(id, name)
                            {
                                location.text = id.toString();
                                navigationPane.pop();
                            }
                            
                            onDoubleTapped: {
                                console.log("UserEvent: LocationFieldDoubleTapped");
                                var p = createLocationPicker();
                                p.performSearch();
                            }
                        }
                    ]
                }
            }
        }
        
        Header {
            id: sites
            property int count: 0
            title: qsTr("Websites") + Retranslate.onLanguageChanged
            visible: count > 0
            subtitle: count
        }
        
        ListView
        {
            visible: sites.visible
            scrollRole: ScrollRole.Main
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            function deleteSite(ListItemData)
            {
                tafsirHelper.removeWebsite(createRijaal, ListItemData.id);
                tafsirHelper.fetchAllWebsites(createRijaal, individualId);
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        id: sli
                        imageSource: ListItemData.imageSource
                        title: ListItemData.uri
                        
                        contextActions: [
                            ActionSet
                            {
                                subtitle: sli.description
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_site.png"
                                    title: qsTr("Delete") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: DeleteSite");
                                        sli.ListItem.view.deleteSite(ListItemData);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
            
            onTriggered: {
                var d = adm.data(indexPath);
                persist.donate(d.uri);
            }
        }
    }
    
    
    
    function createLocationPicker()
    {
        definition.source = "LocationPickerPage.qml";
        var p = definition.createObject();
        p.picked.connect(dth.onPicked);
        
        navigationPane.push(p);
        
        return p;
    }
}