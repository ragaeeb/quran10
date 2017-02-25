import bb.cascades 1.2
import com.canadainc.data 1.0

Page
{
    id: searchRoot
    property string searchText
    property alias listControl: listView
    property alias busyControl: busy
    property alias model: adm
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
        }
    }
    
    function reload() {
        searchTextChanged();
    }
    
    function cleanUp()
    {
        tutorial.tutorialFinished.disconnect(onTutorialFinished);
        helper.textualChange.disconnect(reload);
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(searchRoot, listView);
        tutorial.tutorialFinished.connect(onTutorialFinished);
        helper.textualChange.connect(reload);
    }
    
    function extractTokens(trimmed)
    {
        var elements = trimmed.match(/(?:[^\s"]+|"[^"]*")+/g);
        
        for (var j = elements.length-1; j >= 0; j--) {
            elements[j] = elements[j].replace(/^"(.*)"$/, '$1');
        }
        
        return elements;
    }
    
    onPerformSearch: {
        var trimmed = searchField.text.trim();
        
        if (trimmed.length > 0)
        {
            titleBar.kindProperties.expandableArea.expanded = false;
            busy.delegateActive = true;
            noElements.delegateActive = false;
            listView.hasTashkeel = trimmed.match(/[\u0617-\u061A\u064B-\u0652]/g) != null;
            
            helper.searchQuery(listView, extractTokens(trimmed), included.surahId > 0 ? [included.surahId] : []);
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
                                
                                gestureHandlers: [
                                    TapHandler {
                                        onTapped: {
                                            reporter.record("ChapterRestrictionTapped");
                                            restrictButton.clicked();
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
                                    
                                    if (Qt.navigationPane) {
                                        Qt.navigationPane.pop();
                                    } else {
                                        navigationPane.pop();
                                    }
                                }
                                
                                onClicked: {
                                    console.log("UserEvent: EditRestrictSurahSearch");
                                    
                                    var picker = Qt.launch("SurahPickerPage.qml");
                                    picker.picked.connect(onPicked);
                                    picker.ready();
                                    
                                    reporter.record("EditRestrictSurahSearch");
                                }
                                
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
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
                        tutorial.execBelowTitleBar("searchField", qsTr("Type your search query in the text field and press the Enter key on the keyboard. You can surround your text with double-quotes to search for consecutive words.") );
                    }
                    
                    onStarted: {
                        searchField.requestFocus();
                    }
                    
                    onEnded: {
                        tutorial.execActionBar("searchAction", qsTr("Tap here to perform the search or simply press the Enter key on the keyboard.") );
                        tutorial.execTitle("tapSearchTitle", qsTr("Tap on the title bar to expand it and see more search options.") );
                        
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
                property bool hasTashkeel: false
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
                            bodyText.text: ListItem.view.hasTashkeel ? ListItemData.content : ListItemData.searchable
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
                        
                        if (data.length > 0) {
                            searchDecorator.decorateSearchResults(data, adm, extractTokens(searchField.text.trim()), data[0].searchable ? listView.hasTashkeel ? "content" : "searchable" : "translation" );
                            tutorial.execCentered("openSearchResult", qsTr("You can tap on the list item to go to the ayat that this matches to.") );
                        }
                    } else if (id == QueryId.FetchAyats) {
                        adm.append(data);
                    }
                    
                    updateState();
                }
                
                onTriggered: {
                    console.log("UserEvent: AyatTriggeredFromSearch");
                    var d = dataModel.data(indexPath);
                    picked(d.surah_id, d.verse_number);
                    
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
        
        SearchDecorator {
            id: searchDecorator
        }
    ]
}