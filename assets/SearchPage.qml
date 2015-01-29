import bb.cascades 1.0
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
    signal performSearch()
    signal itemTapped(variant indexPath);
    signal totalResultsFound(int total)
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onSearchTextChanged: {
        searchField.text = searchText;
        searchField.input.submitted(searchField);
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(searchRoot, listView);
    }
    
    onPerformSearch: {
        var trimmed = searchField.text.trim();
        
        if (trimmed.length > 0)
        {
            titleBar.kindProperties.expandableArea.expanded = false;
            busy.delegateActive = true;
            noElements.delegateActive = false;
            
            var additional = [];
            
            for (var i = queryFields.length-1; i >= 0; i--)
            {
                var current = queryFields[i];
                additional.push( current.queryValue.trim() );
            }
            
            helper.searchQuery(listView, trimmed, additional, andMode, shortNarrations.checked);
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
    
    actions: [
        ActionItem {
            id: searchAction
            imageSource: "images/menu/ic_search.png"
            title: qsTr("Search") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: SearchActionTriggered");
                performSearch();
            }
        },
        
        ActionItem {
            imageSource: "images/menu/ic_add_search.png"
            title: qsTr("Add") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: AddSearchFieldTriggered");
                
                definition.source = "SearchConstraint.qml";
                var additional = definition.createObject();
                searchContainer.insert(1, additional);
                
                additional.textField.requestFocus();
                
                additional.startSearch.connect(performSearch);
                var queryFieldsLocal = queryFields;
                queryFieldsLocal.push(additional);
                queryFields = queryFieldsLocal;
            }
        },
        
        ActionItem
        {
            imageSource: "images/menu/ic_search_append.png"
            title: qsTr("Append") + Retranslate.onLanguageChanged
            
            function onNarrationsSelected(ids)
            {
                adm.insert(0, ids);
                
                while (navigationPane.top != searchRoot) {
                    navigationPane.pop();
                }
                
                updateState();
                
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
            }
            
            onTriggered: {
                definition.source = "SearchPickerPage.qml";
                var searchPage = definition.createObject();
                searchPage.doAppend = true;
                
                searchPage.narrationsSelected.connect(onNarrationsSelected);
                navigationPane.push(searchPage);
            }
        },
        
        DeleteActionItem
        {
            id: removeSearchAction
            imageSource: "images/menu/ic_search_remove.png"
            title: qsTr("Remove Search Fields") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: RemoveSearchFields");
                
                for (var i = queryFields.length-1; i >= 0; i--) {
                    searchContainer.remove(queryFields[i]);
                }
                
                var newFields = [];
                queryFields = newFields;
                searchField.resetText();
                searchField.requestFocus();
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
                onExpandedChanged: {
                    console.log("UserEvent: ExcludeExpanded", expanded);
                }
                
                content: ScrollView
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    Container
                    {
                        id: excludeContainer
                        horizontalAlignment: HorizontalAlignment.Fill
                        topPadding: 5
                        
                        Container
                        {
                            leftPadding: 10; rightPadding: 10
                            
                            CheckBox {
                                id: shortNarrations
                                text: qsTr("Short Narrations Only") + Retranslate.onLanguageChanged
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
                flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
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
                    fromY: -200
                    toY: 0
                    easingCurve: StockCurve.SineOut
                    duration: 350
                    
                    onCreationCompleted: {
                        play();
                    }
                    
                    onStarted: {
                        searchField.requestFocus();
                    }
                    
                    onEnded: {
                        if ( persist.tutorial( "tutorialSearchField", qsTr("Type your search query in the text field and press the Enter key on the keyboard."), "asset:///images/tabs/ic_search.png" ) ) {}
                        else if ( persist.tutorial( "tutorialConstraint", qsTr("Tap on the icon at the bottom of the action bar if you want to add additional constraints to the search."), "asset:///images/menu/ic_add.png" ) ) {}
                        else if ( persist.tutorial( "tutorialTipSearchHome", qsTr("Tip: You can start a search query directly from your home screen without even opening the app! Simply tap on the 'Search' icon on your home screen (or begin typing at the home screen on Q10/Q5 devices) and choose 'Sunnah10' from the search results. That will launch the app and initiate the search."), "asset:///images/menu/ic_bio.png" ) ) {}
                        else if ( persist.tutorial( "tutorialTipSearchHome", qsTr("Tip: If you want to start at the Search tab instead of the Bookmarks/Favourites tab, swipe-down from the top-bezel, go to Settings, and enable 'Start At Search Tab'."), "asset:///images/menu/ic_settings.png" ) ) {}
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
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                background: Color.Black
                opacity: 0
                
                animations: [
                    FadeTransition {
                        id: bgFader
                        fromOpacity: 0
                        toOpacity: 0.4
                        duration: 1000
                        delay: 500
                        easingCurve: StockCurve.CubicOut
                    }
                ]
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

                layout: StackListLayout {
                    headerMode: ListHeaderMode.Sticky
                }
                
                property ImagePaintDefinition selectedItemBack: ImagePaintDefinition {
                    imageSource: "images/backgrounds/header_bg.png"
                }
                
                animations: [
                    FadeTransition
                    {
                        id: fader
                        fromOpacity: 0
                        toOpacity: 1
                        easingCurve: StockCurve.QuinticIn
                        duration: 750
                        
                        onEnded: {
                            bgFader.play();
                        }
                    }
                ]
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        Container
                        {
                            id: rootItem
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            background: ListItem.active || ListItem.selected ? ListItem.view.selectedItemBack.imagePaint : undefined
                            
                            Header {
                                id: header
                                title: ListItemData.name
                                subtitle: "%1:%2".arg(ListItemData.surah_id).arg(ListItemData.verse_id)
                            }
                            
                            Container
                            {
                                horizontalAlignment: HorizontalAlignment.Fill
                                leftPadding: 10; rightPadding: 10; bottomPadding: 10
                                
                                Label {
                                    id: bodyLabel
                                    content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                                    multiline: true
                                    text: ListItemData.ayatText
                                    textStyle.color: rootItem.ListItem.active || rootItem.ListItem.selected ? Color.Black : undefined
                                    textStyle.base: global.textFont
                                }
                            }
                            
                            opacity: 0
                            animations: [
                                FadeTransition
                                {
                                    id: showAnim
                                    fromOpacity: 0
                                    toOpacity: 1
                                    easingCurve: StockCurve.QuinticOut
                                    duration: Math.max( 200, Math.min( rootItem.ListItem.indexPath[0]*300, 750 ) );
                                }
                            ]
                            
                            ListItem.onInitializedChanged: {
                                if (initialized) {
                                    showAnim.play();
                                }
                            }
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
                        
                        updateState();
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: AyatTriggeredFromSearch");
                    itemTapped(indexPath);
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