import bb.cascades 1.2
import com.canadainc.data 1.0

Page
{
    id: searchRoot
    property string searchText
    property variant queryFields: []
    property bool andMode: true
    property alias listControl: listView
    property alias busyControl: busy
    property alias def: definition
    property alias model: adm
    property variant googleResults: []
    signal performSearch()
    signal picked(int surahId, int verseId);
    signal totalResultsFound(int total)
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onSearchTextChanged: {
        searchField.text = searchText;
        searchField.input.submitted(searchField);
    }
    
    function onTutorialFinished(key)
    {
        if (key == "tapSearchTitle") {
            titleBar.kindProperties.expandableArea.expanded = true;
            tutorial.execBelowTitleBar("searchOptions", qsTr("Tap on the '%1' button to restrict the search to only a specific surah.").arg(restrictButton.text) );
        } if (key == "searchOptions") {
            tutorial.execBelowTitleBar("searchGoogle", qsTr("Sometimes the translations are not the same depending on where you got your translated text from. Quran10 can also search Google to find a better match than the ones found in the app. Enable the '%1' check box to enable it.").arg(searchGoogleCheckBox.text), deviceUtils.du(8) );
        } else if (key == "searchGoogle") {
            titleBar.kindProperties.expandableArea.expanded = false;
        }
    }
    
    function onCaptured(all, cookie)
    {
        if (all && all.length > 0)
        {
            helper.fetchAyats(listView, all);
            reporter.record("GoogleResults", all.length.toString());
        }
    }
    
    function reload() {
        searchTextChanged();
    }
    
    function cleanUp()
    {
        tutorial.tutorialFinished.disconnect(onTutorialFinished);
        app.ayatsCaptured.disconnect(onCaptured);
        helper.textualChange.disconnect(reload);
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(searchRoot, listView);
        tutorial.tutorialFinished.connect(onTutorialFinished);
        app.ayatsCaptured.connect(onCaptured);
        helper.textualChange.connect(reload);
    }
    
    function getAdditionalQueries()
    {
        var additional = [];
        
        for (var i = queryFields.length-1; i >= 0; i--)
        {
            var current = queryFields[i];
            additional.push( current.queryValue.trim() );
        }
        
        return additional;
    }
    
    onPerformSearch: {
        var trimmed = searchField.text.trim();
        
        if (trimmed.length > 0)
        {
            titleBar.kindProperties.expandableArea.expanded = false;
            busy.delegateActive = true;
            noElements.delegateActive = false;
            
            var additional = getAdditionalQueries();
            
            googleResults = [];
            helper.searchQuery(listView, trimmed, included.surahId, additional, andMode);
            
            if ( additional.length == 0 && persist.getValueFor("searchGoogle") == 1 ) {
                offloader.searchGoogle(trimmed);
            }
        }
    }
    
    function updateState()
    {
        noElements.delegateActive = adm.isEmpty();
        listView.visible = !adm.isEmpty();
        
        if (listView.opacity == 0) {
            fader.play();
        }
        
        totalResultsFound( adm.size() );
    }
    
    onActionMenuVisualStateChanged: {
        if (actionMenuVisualState == ActionMenuVisualState.VisibleFull) {
            tutorial.execActionBar( "removeConstraints", qsTr("Tap on the '%1' action to clear all the constraint fields.").arg(removeSearchAction.title), "x" );
        }
        
        reporter.record("SearchPageActionMenu", actionMenuVisualState.toString());
    }
    
    actions: [
        ActionItem {
            id: searchAction
            imageSource: "images/menu/ic_search_action.png"
            title: qsTr("Search") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: SearchActionTriggered");
                performSearch();
                
                reporter.record("SearchActionTriggered");
            }
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Search
                }
            ]
        },
        
        ActionItem {
            imageSource: "images/menu/ic_add_search.png"
            title: qsTr("Add") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: AddSearchField");
                
                definition.source = "SearchConstraint.qml";
                var additional = definition.createObject();
                searchContainer.insert(1, additional);
                
                additional.textField.requestFocus();
                
                additional.startSearch.connect(performSearch);
                var queryFieldsLocal = queryFields;
                queryFieldsLocal.push(additional);
                queryFields = queryFieldsLocal;
                
                reporter.record("AddSearchField");
            }
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
        },
        
        DeleteActionItem
        {
            id: removeSearchAction
            imageSource: "images/menu/ic_search_remove.png"
            title: qsTr("Remove Constraints") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: RemoveConstraints");
                
                for (var i = queryFields.length-1; i >= 0; i--) {
                    searchContainer.remove(queryFields[i]);
                }
                
                var newFields = [];
                queryFields = newFields;
                searchField.resetText();
                searchField.requestFocus();
                
                reporter.record("RemoveConstraints");
            }
        }
    ]
    
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
                
                Label {
                    text: qsTr("Search") + Retranslate.onLanguageChanged
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.base: SystemDefaults.TextStyles.BigText
                }
            }
            
            expandableArea
            {
                content: ScrollView
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    Container
                    {
                        id: excludeContainer
                        horizontalAlignment: HorizontalAlignment.Fill
                        leftPadding: 10; rightPadding: 10; bottomPadding: 10
                        
                        Container
                        {
                            horizontalAlignment: HorizontalAlignment.Fill
                            
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            
                            StandardListItem
                            {
                                id: included
                                property int surahId
                                visible: surahId > 0
                                horizontalAlignment: HorizontalAlignment.Fill
                                
                                function onDataLoaded(id, data)
                                {
                                    included.title = data[0].name;
                                    included.imageSource = "images/ic_quran.png";
                                    
                                    if (helper.showTranslation) {
                                        included.description = data[0].transliteration;
                                    }
                                }
                                
                                onVisibleChanged: {
                                    if (visible) {
                                        tutorial.execBelowTitleBar("removeSearchRestriction", qsTr("Press and hold on the '%1' button and choose 'Delete' from the menu to clear the restriction.").arg(included.title) );
                                    }
                                }
                                
                                onSurahIdChanged: {
                                    if (surahId > 0) {
                                        helper.fetchSurahHeader(included, surahId);
                                    } else {
                                        included.resetTitle();
                                        included.resetDescription();
                                        included.resetImageSource();
                                    }
                                }
                                
                                contextActions: [
                                    ActionSet
                                    {
                                        title: qsTr("Remove Restriction") + Retranslate.onLanguageChanged
                                        subtitle: qsTr("Don't restrict to %1").arg(included.title)
                                        
                                        DeleteActionItem
                                        {
                                            id: cancelSurah
                                            imageSource: "images/dropdown/cancel_search_surah.png"
                                            
                                            onTriggered: {
                                                console.log("UserEvent: CancelRestrictSurahSearch");
                                                included.surahId = 0;
                                                
                                                reporter.record("CancelRestrictSurahSearch");
                                            }
                                        }
                                    }
                                ]
                            }
                            
                            Button
                            {
                                id: restrictButton
                                imageSource: "images/dropdown/edit_search_surah.png"
                                text: qsTr("Restrict to Chapter") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Fill
                                visible: !included.visible
                                
                                function onPicked(chapter, verse)
                                {
                                    included.surahId = chapter;
                                    navigationPane.pop();
                                }
                                
                                onClicked: {
                                    console.log("UserEvent: EditRestrictSurahSearch");
                                    
                                    definition.source = "SurahPickerPage.qml";
                                    var picker = definition.createObject();
                                    
                                    picker.picked.connect(onPicked);
                                    navigationPane.push(picker);
                                    
                                    picker.ready();
                                    
                                    reporter.record("EditRestrictSurahSearch");
                                }
                                
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                        }
                        
                        PersistCheckBox
                        {
                            id: searchGoogleCheckBox
                            topMargin: 20
                            enabled: helper.showTranslation
                            key: "searchGoogle"
                            text: qsTr("Use Google Assitance") + Retranslate.onLanguageChanged
                            
                            onValueChanged: {
                                reporter.record("UseGoogle", checked.toString());
                            }
                        }
                    }
                }
            }
        }
    }
    
    Container
    {
        id: searchContainer
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        background: bg.imagePaint
        
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
                    reporter.record("SearchEnterPressed");
                }
            }
            
            onCreationCompleted: {
                input["keyLayout"] = 7;
            }
            
            animations: [
                TranslateTransition {
                    fromY: -200
                    toY: 0
                    easingCurve: StockCurve.SineOut
                    duration: 350
                    
                    onCreationCompleted: {
                        play();
                        tutorial.execBelowTitleBar("searchField", qsTr("Type your search query in the text field and press the Enter key on the keyboard.") );
                    }
                    
                    onStarted: {
                        searchField.requestFocus();
                    }
                    
                    onEnded: {
                        tutorial.execActionBar("searchAction", qsTr("Tap here to perform the search or simply press the Enter key on the keyboard.") );
                        tutorial.execTitle("tapSearchTitle", qsTr("Tap on the title bar to expand it and see more search options.") );
                        var isNew = tutorial.execActionBar("constraint", qsTr("Tap on the icon at the bottom of the action bar if you want to add additional constraints to the search."), "r" );
                        
                        if (!isNew) {
                            tutorial.execCentered("tipSearchHome", qsTr("Tip: You can start a search query directly from your home screen without even opening the app! Simply tap on the 'Search' icon on your home screen (or begin typing at the home screen on Q10/Q5/Passport devices) and choose 'Quran10' from the search results. That will launch the app and initiate the search.") );
                        }
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
                graphic: "images/placeholders/empty_search.png"
                labelText: qsTr("No results found for your query. Try another query.") + Retranslate.onLanguageChanged
                
                onImageTapped: {
                    searchField.requestFocus();
                }
            }
            
            ListView
            {
                id: listView
                opacity: 0
                property int translationSize: helper.translationSize
                property int primarySize: helper.primarySize
                scrollRole: ScrollRole.Main

                layout: StackListLayout {
                    headerMode: ListHeaderMode.Sticky
                }
                
                function itemType(data, indexPath)
                {
                    if (data.searchable) {
                        return "arabic";
                    } else {
                        return "translated";
                    }
                }
                
                animations: [
                    FadeTransition
                    {
                        id: fader
                        fromOpacity: 0
                        toOpacity: 1
                        easingCurve: StockCurve.QuinticIn
                        duration: 750
                    }
                ]
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        type: "arabic"
                        
                        SearchListItem
                        {
                            bodyText.text: ListItemData.searchable
                            bodyText.textStyle.fontSizeValue: ListItem.view.primarySize
                            
                            ListItem.onInitializedChanged: {
                                if (initialized) {
                                    bodyText.textStyle.base = global.textFont;
                                }
                            }
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "translated"

                        SearchListItem {
                            bodyText.text: ListItemData.translation
                            bodyText.textStyle.fontSizeValue: ListItem.view.translationSize
                        }
                    }
                ]
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.SearchAyats)
                    {
                        adm.clear();
                        adm.append(data);
                        busy.delegateActive = false;
                        
                        offloader.decorateSearchResults(data, searchField.text, adm, getAdditionalQueries());
                    } else if (id == QueryId.FetchAyats) {
                        adm.append(data);
                    }
                    
                    updateState();
                }
                
                onTriggered: {
                    console.log("UserEvent: AyatTriggeredFromSearch");
                    var d = dataModel.data(indexPath);
                    picked(d.surah_id, d.verse_id);
                    
                    reporter.record("AyatTriggeredFromSearch");
                }
            }
            
            ProgressControl
            {
                id: busy
                asset: "images/progress/loading_search.png"
            }
        }
    }
    
    attachedObjects: [
        ImagePaintDefinition {
            id: bg
            imageSource: "images/backgrounds/background.png"
        },
        
        ComponentDefinition {
            id: definition
        }
    ]
}