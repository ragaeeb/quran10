import bb.cascades 1.3
import bb.system 1.2
import com.canadainc.data 1.0

Page
{
    id: createRijaal
    property variant individualId
    signal createIndividual(variant id, string prefix, string name, string kunya, string displayName, bool hidden, int birth, int death, bool female, variant location, bool companion)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onIndividualIdChanged: {
        if (individualId)
        {
            tafsirHelper.fetchIndividualData(createRijaal, individualId);
            tafsirHelper.fetchAllWebsites(createRijaal, individualId);
        }
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
                var uri = persist.showBlockingPrompt( qsTr("Enter url"), qsTr("Please enter the website address for this individual:"), "http://", qsTr("Enter url (ie: http://mtws.com)"), 100, false, qsTr("Save"), qsTr("Cancel"), SystemUiInputMode.Url ).trim();

                if (uri.length > 0)
                {
                    if ( textUtils.isUrl(uri) ) {
                        tafsirHelper.addWebsite(createRijaal, individualId, uri);
                    } else {
                        persist.showToast( qsTr("Invalid URL entered!"), "images/menu/ic_remove_site.png" );
                        console.log("FailedRegex", uri);
                    }
                }
            }
        },
        
        ActionItem
        {
            id: addEmail
            imageSource: "images/menu/ic_add_email.png"
            title: qsTr("Add Email") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: NewEmail");
                var email = persist.showBlockingPrompt( qsTr("Enter email"), qsTr("Please enter the email address for this individual:"), "", qsTr("Enter email (ie: abc@hotmail.com)"), 100, false, qsTr("Save"), qsTr("Cancel"), SystemUiInputMode.Email ).trim();

                if (email.length > 0)
                {
                    if ( textUtils.isEmail(email) ) {
                        tafsirHelper.addWebsite(createRijaal, individualId, email);
                    } else {
                        persist.showToast( qsTr("Invalid email entered!"), "images/menu/ic_remove_email.png" );
                        console.log("FailedRegex", email);
                    }
                }
            }
        },
        
        ActionItem
        {
            id: addPhone
            imageSource: "images/menu/ic_add_phone.png"
            title: qsTr("Add Phone") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: NewPhone");
                var phone = persist.showBlockingPrompt( qsTr("Enter phone number"), qsTr("Please enter the phone number for this individual:"), "", qsTr("Enter phone (ie: +44133441623)"), 100, false, qsTr("Save"), qsTr("Cancel"), SystemUiInputMode.Phone ).trim();
                
                if (phone.length > 0)
                {
                    if ( textUtils.isPhoneNumber(phone) ) {
                        tafsirHelper.addWebsite(createRijaal, individualId, phone);
                    } else {
                        persist.showToast( qsTr("Invalid email entered!"), "images/menu/ic_remove_phone.png" );
                        console.log("FailedRegex", phone);
                    }
                }
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
            companion.checked = data.is_companion == 1;
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
            results = offloader.fillType(results, id);
            adm.clear();
            adm.append(results);
        } else if (id == QueryId.AddWebsite) {
            persist.showToast( qsTr("Website added!"), "asset:///images/menu/ic_add_site.png" );
            tafsirHelper.fetchAllWebsites(createRijaal, individualId);
        } else if (id == QueryId.RemoveWebsite) {
            persist.showToast( qsTr("Entry removed!"), "asset:///images/menu/ic_remove_site.png" );
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
                    createIndividual(individualId, prefix.text.trim(), name.text.trim(), kunya.text.trim(), displayName.text.trim(), hidden.checked, parseInt( birth.text.trim() ), parseInt( death.text.trim() ), female.checked, location.text.trim(), companion.checked );
                } else if (!location.validator.valid) {
                    persist.showToast( qsTr("Invalid location specified!"), "images/toast/incomplete_field.png" );
                } else {
                    persist.showToast( qsTr("Invalid name!"), "images/toast/incomplete_field.png" );
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
                    
                    CheckBox {
                        id: companion
                        text: qsTr("Companion") + Retranslate.onLanguageChanged
                    }
                }
                
                TextField
                {
                    id: prefix
                    hintText: qsTr("Prefix (ie: al-Hafidh, Shaykh)") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                    input.submitKey: SubmitKey.Next
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                    
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
                    input.submitKey: SubmitKey.Next
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                    
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
                    input.submitKey: SubmitKey.Next
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                    
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
                    input.submitKey: SubmitKey.Next
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                    
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
                    input.submitKey: SubmitKey.Next
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                    
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
                    input.submitKey: SubmitKey.Next
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                    
                    gestureHandlers: [
                        DoubleTapHandler {
                            onDoubleTapped: {
                                console.log("UserEvent: DisplayNameDoubleTapped");
                                displayName.text = textUtils.toTitleCase( persist.getClipboardText() );
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
                    input.submitKey: SubmitKey.Search

                    input.onSubmitted: {
                        console.log("UserEvent: CityOfBirthSubmit");
                        location.validator.validate();
                    }
                    
                    validator: Validator
                    {
                        errorMessage: qsTr("No locations found...") + Retranslate.onLanguageChanged;
                        mode: ValidationMode.Custom

                        function parseCoordinate(input)
                        {
                            var tokens = input.trim().split(" ");
                            var value = parseFloat( tokens[0].trim() );

                            if ( tokens[1].trim() == "S" || tokens[1].trim() == "W") {
                                value *= -1;
                            }
                            
                            return value;
                        }

                        onValidate: {
                            var trimmed = location.text.trim();
                            
                            if (trimmed.length == 0) {
                                valid = true;
                            } else {
                                if ( trimmed.match("\\d.+\\s[NS]{1},\\s+\\d.+\\s[EW]{1}") )
                                {
                                    createLocationPicker();
                                    var tokens = trimmed.split(",");
                                    app.geoLookup( parseCoordinate(tokens[0]), parseCoordinate(tokens[1]) );
                                } else if ( trimmed.match("-{0,1}\\d.+,\\s+-{0,1}\\d.+") ) {
                                    createLocationPicker();
                                    var tokens = trimmed.split(",");
                                    app.geoLookup( parseFloat( tokens[0].trim() ), parseFloat( tokens[1].trim() ) );
                                } else if ( trimmed.match("\\d+") ) {
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
            title: qsTr("Websites, & Contact Information") + Retranslate.onLanguageChanged
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
            
            function itemType(data, indexPath) {
                return data.type;
            }
            
            function deleteSite(ListItemData)
            {
                tafsirHelper.removeWebsite(createRijaal, ListItemData.id);
                
                if (ListItemData.type == "email") {
                    persist.showToast( qsTr("Email address removed!"), "images/menu/ic_remove_email.png" );
                } else if (ListItemData.type == "phone") {
                    persist.showToast( qsTr("Phone number removed!"), "images/menu/ic_remove_phone.png" );
                } else if (ListItemData.type == "uri") {
                    persist.showToast( qsTr("Website address removed!"), "images/menu/ic_remove_site.png" );
                }
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    type: "website"
                    
                    StandardListItem
                    {
                        id: sli
                        imageSource: ListItemData.imageSource
                        title: ListItemData.uri
                        
                        contextActions: [
                            ActionSet
                            {
                                title: sli.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_site.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: DeleteSite");
                                        sli.ListItem.view.deleteSite(ListItemData);
                                    }
                                }
                            }
                        ]
                    }
                },
                
                ListItemComponent
                {
                    type: "email"
                    
                    StandardListItem
                    {
                        id: sliEmail
                        imageSource: "images/list/ic_email.png"
                        title: ListItemData.uri
                        
                        contextActions: [
                            ActionSet
                            {
                                title: sliEmail.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_email.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: DeleteSite");
                                        sli.ListItem.view.deleteSite(ListItemData);
                                    }
                                }
                            }
                        ]
                    }
                },
                
                ListItemComponent
                {
                    type: "phone"
                    
                    StandardListItem
                    {
                        id: sliPhone
                        imageSource: "images/list/ic_phone.png"
                        title: ListItemData.uri
                        
                        contextActions: [
                            ActionSet
                            {
                                title: sliPhone.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_phone.png"
                                    
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