import bb.cascades 1.2
import com.canadainc.data 1.0

Page
{
    id: mainPage
    signal picked(int chapter, int verse)
    signal juzPicked(int juzId)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property alias pickerList: listView
    property bool showJuz: false
    property alias sortValue: sortOrder.selectedValue

    titleBar: TitleBar
    {
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties
        {
            Container
            {
                id: titleBar
                background: titleBack.imagePaint
                rightPadding: 50
                layout: DockLayout {}
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Top
                
                ImageView
                {
                    imageSource: "images/title/logo.png"
                    loadEffect: ImageViewLoadEffect.FadeZoom
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Center
                    opacity: 0
                    
                    animations: [
                        FadeTransition {
                            id: fadeInLogo
                            easingCurve: StockCurve.CubicIn
                            fromOpacity: 0
                            toOpacity: 1
                            duration: 1000
                            
                            onEnded: {
                                if (showJuz)
                                {
                                    quote.process();
                                    tm.process();
                                    bookmarkHelper.fetchLastProgress(button);
                                    global.lastPositionUpdated.connect(button.onLastPositionUpdated);
                                }
                            }
                        }
                    ]
                }
                
                Container
                {
                    id: button
                    leftPadding: 15;
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    visible: false
                    layout: DockLayout {}
                    
                    Button
                    {
                        id: buttonControl
                        property variant progressData
                        text: progressData ? progressData.surah_id+":"+progressData.verse_id : ""
                        imageSource: "images/dropdown/saved_bookmark.png"
                        verticalAlignment: VerticalAlignment.Center
                        maxWidth: 150
                        translationX: -250
                        scaleX: 1.1
                        scaleY: 1.1
                        
                        onClicked: {
                            console.log("UserEvent: SavedBookmarkClicked");
                            picked(progressData.surah_id, progressData.verse_id);
                        }
                        
                        animations: [
                            SequentialAnimation
                            {
                                id: rotator
                                
                                TranslateTransition
                                {
                                    fromX: -250
                                    toX: 0
                                    easingCurve: StockCurve.QuinticOut
                                    duration: 750
                                }
                                
                                RotateTransition {
                                    fromAngleZ: 360
                                    toAngleZ: 0
                                    easingCurve: StockCurve.ExponentialOut
                                    duration: 750
                                }
                                
                                ScaleTransition
                                {
                                    fromX: 1.1
                                    fromY: 1.1
                                    toX: 1
                                    toY: 1
                                    duration: 500
                                    easingCurve: StockCurve.DoubleElasticOut
                                }
                            }
                        ]
                    }
                    
                    function onDataLoaded(id, data)
                    {
                        if (id == QueryId.FetchLastProgress && data.length > 0)
                        {
                            buttonControl.progressData = data[0];
                            button.visible = true;
                        }
                    }
                    
                    function onLastPositionUpdated() {
                        bookmarkHelper.fetchLastProgress(button);
                    }
                    
                    contextActions: [
                        ActionSet {
                            title: buttonControl.text
                            subtitle: buttonControl.progressData ? Qt.formatDateTime(buttonControl.progressData.timestamp) : ""
                        }
                    ]
                }
                
                attachedObjects: [
                    ImagePaintDefinition {
                        id: titleBack
                        imageSource: "images/title/title_bg.png"
                    }
                ]
            }
        }
    }
    
    onPeekedAtChanged: {
        listView.secretPeek = peekedAt;
    }
    
    Container
    {
        background: back.imagePaint
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container
            {
                layout: DockLayout {}
                background: Color.Black
                horizontalAlignment: HorizontalAlignment.Fill
                visible: showJuz
                
                PersistDropDown
                {
                    id: sortOrder
                    title: qsTr("Display Options") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    topMargin: 0; bottomMargin: 0
                    
                    Option {
                        id: alphabet
                        text: qsTr("Alphabetical Order") + Retranslate.onLanguageChanged
                        description: qsTr("Sorted by surah name") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/sort_alphabet.png"
                        value: "name"
                    }
                    
                    Option {
                        id: juzOption
                        text: qsTr("Juz") + Retranslate.onLanguageChanged
                        description: qsTr("The surahs will be displayed separated in juz") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/sort_juz.png"
                        value: "juz"
                    }
                    
                    Option {
                        id: normal
                        text: qsTr("Normal") + Retranslate.onLanguageChanged
                        description: qsTr("The surahs will be displayed in the standard order") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/sort_normal.png"
                        value: "normal"
                    }
                    
                    Option {
                        id: recent
                        text: qsTr("Revelation Order") + Retranslate.onLanguageChanged
                        description: qsTr("Display chapters int he order they were revealed") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/sort_revelation.png"
                        value: "revelation_order"
                    }
                    
                    onSelectedOptionChanged: {
                        textField.textChanging(textField.text);
                    }
                }
            }
            
            TextField
            {
                id: textField
                hintText: qsTr("Search surah name or number (ie: '2' for Surah Al-Baqara)...") + Retranslate.onLanguageChanged
                bottomMargin: 0
                horizontalAlignment: HorizontalAlignment.Fill
                topMargin: 0;
                
                onTextChanging: {
                    var ok = true;
                    var textValue = text.trim();
                    
                    if (textValue.length == 0 && sortOrder.selectedOption == juzOption) {
                        helper.fetchAllChapters(listView);
                    } else if ( textValue.match(/^\d{1,3}:\d{1,3}$/) || textValue.match(/^\d{1,3}$/) ) {
                        var tokens = textValue.split(":");
                        var surah = parseInt(tokens[0]);
                        helper.fetchChapter(listView, surah);
                    } else {
                        ok = helper.fetchChapters(listView, textValue);
                    }
                    
                    busy.delegateActive = ok;
                }
                
                input {
                    submitKey: SubmitKey.Submit
                    
                    onSubmitted: {
                        var textValue = text.trim();
                        
                        if ( textValue.match(/^\d{1,3}:\d{1,3}$/) || textValue.match(/^\d{1,3}$/) )
                        {
                            var tokens = textValue.split(":");
                            var surah = parseInt(tokens[0]);
                            
                            if (tokens.length > 0) {
                                var verse = parseInt(tokens[1]);
                                picked(surah, verse);
                            } else {
                                picked(surah, 0);
                            }
                        }
                    }
                }
                
                animations: [
                    TranslateTransition {
                        id: translate
                        fromX: 1000
                        duration: 500
                        
                        onEnded: {
                            if (deviceUtils.isPhysicalKeyboardDevice) {
                                textField.requestFocus();
                            }
                            
                            textField.input["keyLayout"] = 7;
                            deviceUtils.attachTopBottomKeys(mainPage, listView, true);
                            
                            rotator.play();
                        }
                    }
                ]
            }
            
            ListView
            {
                id: listView
                objectName: "listView"
                property bool secretPeek: false
                
                dataModel: GroupDataModel {
                    id: gdm
                    sortingKeys: ["surah_id"]
                    grouping: ItemGrouping.ByFullValue
                }
                
                listItemComponents: [
                    ListItemComponent {
                        type: "header"
                        
                        Header {
                            title: qsTr("Juz %1").arg(ListItemData)
                            subtitle: ListItem.view.dataModel.childCount(ListItem.indexPath)
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "item"
                        
                        StandardListItem
                        {
                            id: sli
                            property bool peek: ListItem.view.secretPeek
                            title: ListItemData.transliteration ? ListItemData.transliteration : ListItemData.name
                            description: ListItemData.transliteration ? ListItemData.name : qsTr("%n ayahs", "", ListItemData.verse_count)
                            status: ListItemData.verse_number ? ListItemData.verse_number : ListItemData.surah_id
                            imageSource: "images/ic_quran.png"
                            contextActions: ActionSet {}
                            
                            onPeekChanged: {
                                if (peek) {
                                    showAnim.play();
                                }
                            }
                            
                            opacity: 0
                            animations: [
                                FadeTransition
                                {
                                    id: showAnim
                                    easingCurve: StockCurve.SineOut
                                    fromOpacity: 0
                                    toOpacity: 1
                                    duration: Math.min( sli.ListItem.indexInSection*300, 750 );
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
                
                onTriggered: {
                    var data = listView.dataModel.data(indexPath);
                    
                    if ( sortOrder.selectedOption != juzOption || indexPath.length > 1 )
                    {
                        console.log("UserEvent: SurahTriggered");
                        picked(data.surah_id, 0);
                    } else {
                        console.log("UserEvent: JuzTriggered");
                        juzPicked(data);
                    }
                }
                
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchChapters)
                    {
                        gdm.grouping = ItemGrouping.None;
                        
                        if (sortOrder.selectedOption == alphabet) {
                            gdm.sortingKeys = [helper.showTranslation ? "transliteration" : "name"];
                        } else if (sortOrder.selectedOption == normal || sortOrder.selectedOption == null) {
                            gdm.sortingKeys = ["surah_id"];
                        } else if (sortOrder.selectedOption == recent) {
                            gdm.sortingKeys = ["revelation_order"];
                        }
                        
                    } else if (id == QueryId.FetchAllChapters) {
                        gdm.grouping = ItemGrouping.ByFullValue;
                        gdm.sortingKeys = ["juz_id", "surah_id", "verse_number"];
                        data = helper.normalizeJuzs(data);
                    }
                    
                    gdm.clear();
                    gdm.insertList(data);
                    noElements.delegateActive = gdm.isEmpty();
                    listView.visible = !noElements.delegateActive;
                    busy.delegateActive = false;
                }
            }
        }
        
        EmptyDelegate
        {
            id: noElements
            graphic: "images/placeholders/empty_chapters.png"
            labelText: qsTr("No chapters matched your search criteria. Please try a different search term.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                console.log("UserEvent: NoChaptersTapped");
                textField.requestFocus();
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_chapters.png"
        }
        
        QuoteOverlay {
            id: quote
        }
        
        PermissionToast
        {
            id: tm
            horizontalAlignment: HorizontalAlignment.Center
            
            function process()
            {
                var allMessages = [];
                var allIcons = [];
                
                if ( !persist.hasSharedFolderAccess() ) {
                    allMessages.push("Warning: It seems like the app does not have access to your Shared Folder. This permission is needed to download the recitation audio and the mushaf pages. If you leave this permission off, some features may not work properly.");
                    allIcons.push("images/toast/ic_no_shared_folder.png");
                }
                
                if (allMessages.length > 0)
                {
                    messages = allMessages;
                    icons = allIcons;
                    delegateActive = true;
                }
            }
        }
    }
    
    function ready()
    {
        sortOrder.key = "surahPickerOption";
        fadeInLogo.play();
        translate.play();
    }
    
    attachedObjects: [
        ImagePaintDefinition {
            id: back
            imageSource: "images/backgrounds/background.png"
        }
    ]
}
