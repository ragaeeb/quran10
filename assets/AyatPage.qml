import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: root
    property int surahId
    property int verseId

    onVerseIdChanged: {
        reload();
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchAyat)
        {
            if (data.length > 0)
            {
                notFound.delegateActive = false;
                
                body.value = data[0].content;
                
                if (data[0].translation) {
                    translation.value = data[0].translation;
                }
                
                var n = data[0].total_similar;
                
                if (n > 0) {
                    titleControl.addOption(similarOption);
                    similarOption.text = qsTr("%n similar", "", n);
                    
                    if ( persist.tutorial( "tutorialSimilarAyat", qsTr("There appears to be other verses with similar wording, choose the '%1 Similar' option at the top to view them in a split screen.").arg(data.length), "asset:///images/dropdown/similar.png" ) ) {}
                }
                
                transliteration.resetText();
                helper.fetchTafsirCountForAyat(root, surahId, verseId);
                helper.fetchSurahHeader(root, surahId);
                busy.delegateActive = false;
            } else { // erroneous ID entered
                notFound.delegateActive = true;
                busy.delegateActive = false;
                console.log("AyatNotFound!");
            }
        } else if (id == QueryId.FetchTafsirCountForAyat && data.length > 0 && data[0].tafsir_count > 0) {
            titleControl.addOption(tafsirOption);
            tafsirOption.tafsirCount = data[0].tafsir_count;
            if ( persist.tutorial( "tutorialTafsir", qsTr("There are explanations of this verse by the people of knowledge! Tap on the '%1 Tafsir' option at the top to view them.").arg(data.length), "asset:///images/dropdown/tafsir.png" ) ) {}
        } else if (id == QueryId.FetchSimilarAyatContent && data.length > 0 && similarOption.selected) {
            pluginsDelegate.control.applyData(data, helper.showTranslation ? translation : body);
        } else if (id == QueryId.FetchSurahHeader && data.length > 0) {
            ayatOption.text = data[0].translation ? data[0].translation : data[0].name;
            babName.title = data[0].transliteration ? data[0].transliteration : data[0].name;
            babName.subtitle = "%1:%2".arg(surahId).arg(verseId);
            
            translation.value = translation.value + "\n\n(" + babName.title + " " + babName.subtitle + ")";
        } else if (id == QueryId.SaveBookmark) {
            persist.showToast( qsTr("Favourite added for Chapter %1, Verse %2").arg(surahId).arg(verseId), "", "asset:///images/menu/ic_bookmark_add.png" );
            global.bookmarksUpdated();
        } else if (id == QueryId.FetchTransliteration) {
            transliteration.text = data[0].html;
        } else if (id == QueryId.FetchAdjacentAyat) {
            if (data.length > 0) {
                surahId = data[0].surah_id;
                verseId = data[0].verse_id;
            } else {
                persist.showToast( qsTr("Ayat not found"), "", "asset:///images/toast/ic_no_ayat_found.png" );
            }
        }
    }
    
    function showExplanation(id)
    {
        definition.source = "AyatTafsirDialog.qml";
        var htd = definition.createObject();
        htd.suitePageId = id;
        htd.open();
    }
    
    function reload()
    {
        busy.delegateActive = true;
        helper.fetchAyat(root, surahId, verseId);
    }
    
    function shift(i)
    {
        helper.fetchAdjacentAyat(root, surahId, verseId, i);
        titleControl.removeOption(similarOption);
        titleControl.removeOption(tafsirOption);
        ayatOption.selected = true;
    }
    
    onCreationCompleted: {
        helper.textualChange.connect(reload);
    }
    
    titleBar: TitleBar
    {
        id: titleControl
        kind: TitleBarKind.Segmented
        selectedOption: ayatOption
        options: [
            Option {
                id: ayatOption
                text: qsTr("Verse") + Retranslate.onLanguageChanged
                imageSource: "images/dropdown/original_ayat.png"
                selected: true
                
                onSelectedChanged: {
                    if (selected) {
                        console.log("UserEvent: AyatOptionSelected");
                        pluginsDelegate.delegateActive = false;
                    }
                }
            },
            
            Option
            {
                id: recitationOption
                text: qsTr("Audio") + Retranslate.onLanguageChanged
                imageSource: "images/dropdown/audio.png"
                
                onSelectedChanged: {
                    if (selected)
                    {
                        console.log("UserEvent: RecitationOptionSelected");
                        pluginsDelegate.source = "RecitationControl.qml";
                        pluginsDelegate.delegateActive = true;
                    } else {
                        if (pluginsDelegate.control.played) {
                            player.stop();
                        }
                    }
                }
            }
        ]
        
        attachedObjects: [
            Option {
                id: similarOption
                imageSource: "images/dropdown/similar.png"
                
                onSelectedChanged: {
                    if (selected)
                    {
                        console.log("UserEvent: SimilarOptionSelected");
                        helper.fetchSimilarAyatContent(root, surahId, verseId);
                        
                        pluginsDelegate.source = "SimilarAyatControl.qml";
                        pluginsDelegate.delegateActive = true;
                    } else {
                        body.text = body.value;
                        translation.text = translation.value;
                    }
                }
            },
            
            Option {
                id: tafsirOption
                property int tafsirCount
                text: qsTr("%n tafsir", "", tafsirCount) + Retranslate.onLanguageChanged
                imageSource: "images/dropdown/tafsir.png"
                
                onSelectedChanged: {
                    if (selected)
                    {
                        console.log("UserEvent: TafsirOptionSelected");
                        pluginsDelegate.source = "AyatTafsirPicker.qml";
                        pluginsDelegate.delegateActive = true;
                    }
                }
            }
        ]
    }
    
    actions: [
        ActionItem {
            enabled: !notFound.delegateActive
            title: qsTr("Mark Favourite") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_mark_favourite.png"
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: MarkFavourite");
                var name = persist.showBlockingPrompt( qsTr("Enter name"), qsTr("You can use this to quickly recognize this ayah in the favourites tab."), translation.value, qsTr("Name..."), 50, true, qsTr("Save") );
                
                if (name.length > 0)
                {
                    var tag = persist.showBlockingPrompt( qsTr("Enter tag"), qsTr("You can use this to categorize related verses together."), "", qsTr("Enter a tag for this bookmark (ie: ramadan). You can leave this blank if you don't want to use a tag."), 50, false, qsTr("Save") );
                    bookmarkHelper.saveBookmark(root, surahId, verseId, name, tag);
                }
            }
        },
        
        ActionItem {
            enabled: !notFound.delegateActive
            title: qsTr("Add Shortcut") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_home.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Search
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: AddShortcutTriggered");
                var name = persist.showBlockingPrompt( qsTr("Enter name"), qsTr("You can use this to quickly recognize this ayah on your home screen."), translation.value, qsTr("Shortcut name..."), 15, true, qsTr("Save") );
                
                if (name.length > 0) {
                    offloader.addToHomeScreen(surahId, verseId, name);
                }
            }
        },
        
        ActionItem
        {
            title: qsTr("Copy") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_copy.png"
            
            onTriggered: {
                console.log("UserEvent: CopyAyat");
                persist.copyToClipboard(body.value+"\n\n"+translation.value);
            }
        },
        
        InvokeActionItem
        {
            imageSource: "images/menu/ic_share.png"
            title: qsTr("Share") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            
            onTriggered: {
                console.log("UserEvent: ShareAyat");
                data = persist.convertToUtf8(body.value+"\n\n"+translation.value);
            }
        },
        
        ActionItem
        {
            title: qsTr("Previous Verse") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_prev_ayat.png"
            enabled: !(surahId == 1 && verseId == 1)
            
            onTriggered: {
                console.log("UserEvent: PrevAyat");
                shift(-1);
            }
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.PreviousSection
                }
            ]
        },
        
        ActionItem
        {
            title: qsTr("Next Verse") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_next_ayat.png"
            enabled: !(surahId == 114 && verseId == 6)
            
            onTriggered: {
                console.log("UserEvent: NextAyat");
                shift(1);
            }
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.NextSection
                }
            ]
        }
    ]
    
    Container
    {
        background: bg.imagePaint
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}

        attachedObjects: [
            ImagePaintDefinition {
                id: bg
                imageSource: "images/backgrounds/background_ayat_page.jpg"
            }
        ]

        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: Color.Black
            opacity: 0
            
            animations: [
                FadeTransition
                {
                    fromOpacity: 0
                    toOpacity: 0.5
                    duration: 1000
                    delay: 500
                    easingCurve: StockCurve.QuadraticOut
                    
                    onCreationCompleted: {
                        play();
                    }
                    
                    onEnded: {
                        /*
                        if ( persist.tutorial( "tutorialPinchHadith", qsTr("To increase and decrease the font size of the text simply do a pinch gesture here!"), "asset:///images/menu/ic_top.png" ) ) {}
                        else if ( persist.tutorial( "tutorialMarkFav", qsTr("To quickly access this hadith again, tap on the 'Mark Favourite' action at the bottom to put it in the Bookmarks tab that shows up in the start of the app."), "asset:///images/menu/ic_bookmark_add.png" ) ) {}
                        else if ( persist.tutorial( "tutorialAddShortcutHome", qsTr("To quickly access this hadith again, tap on the 'Add Shortcut' action at the bottom to pin it to your homescreen."), "asset:///images/menu/ic_home_add.png" ) ) {}
                        else if ( persist.tutorial( "tutorialShare", qsTr("To share this hadith with your friends tap on the 'Share' action at the bottom."), "asset:///images/menu/ic_share.png" ) ) {}
                        else if ( persist.tutorial( "tutorialReportMistake", qsTr("If you notice any mistakes with the text or the translation of the hadith, tap on the '...' icon at the bottom-right to use the menu, and use the 'Report Mistake' action from the menu."), "asset:///images/menu/ic_report_error.png" ) ) {}
                        else if ( persist.reviewed() ) {}
                        else if ( reporter.performCII() ) {} */
                    }
                }
            ]
        }
        
        EmptyDelegate
        {
            id: notFound
            graphic: "images/placeholders/no_match.png"
            labelText: qsTr("The ayat was not found in the database.") + Retranslate.onLanguageChanged
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill

            ControlDelegate
            {
                id: pluginsDelegate
                topMargin: 0; bottomMargin: 0
                delegateActive: false
            }
            
            Header
            {
                id: babName
                accessibility.name: qsTr("Chapter Name") + Retranslate.onLanguageChanged
                accessibility.description: qsTr("Displays the chapter information") + Retranslate.onLanguageChanged
                
                gestureHandlers: [
                    TapHandler
                    {
                        onTapped: {
                            if (similarOption.selected) {
                                pluginsDelegate.control.ratio = 0.4;
                            }
                        }
                    }
                ]
            }
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                
                Label
                {
                    id: transliteration
                    visible: text.length > 0
                    horizontalAlignment: HorizontalAlignment.Fill
                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                    multiline: true
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: helper.translationSize
                    opacity: 0
                    
                    onVisibleChanged: {
                        if (visible) {
                            transFade.play();
                        }
                    }
                    
                    animations: [
                        FadeTransition
                        {
                            id: transFade
                            fromOpacity: 0
                            toOpacity: 1
                            duration: 500
                            easingCurve: StockCurve.ExponentialIn
                        }
                    ]
                }
            }
            
            ScrollView
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    leftPadding: ui.sdu(1)
                    rightPadding: ui.sdu(1)
                    
                    Label
                    {
                        id: body
                        property string value
                        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.fontSizeValue: helper.primarySize
                        textStyle.base: global.textFont
                        textStyle.textAlign: TextAlign.Right
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        multiline: true
                        
                        onValueChanged: {
                            text = value;
                        }
                        
                        gestureHandlers: [
                            TapHandler {
                                onTapped: {
                                    console.log("UserEvent: TappedAyatArabic");
                                    
                                    if (!transliteration.visible) {
                                        helper.fetchTransliteration(root, surahId, verseId);
                                    }
                                }
                            },
                            
                            FontSizePincher
                            {
                                key: "primarySize"
                                minValue: 6
                                maxValue: 30
                                userEventId: "PinchedArabic"
                            }
                        ]
                        
                        contextActions: [
                            ActionSet
                            {
                                title: translation.value
                                
                                ActionItem
                                {
                                    title: qsTr("Copy") + Retranslate.onLanguageChanged
                                    imageSource: "images/menu/ic_copy.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: CopyArabicOnly");
                                        persist.copyToClipboard(body.value);
                                    }
                                }
                                
                                InvokeActionItem
                                {
                                    imageSource: "images/menu/ic_share.png"
                                    title: qsTr("Share") + Retranslate.onLanguageChanged
                                    
                                    query {
                                        mimeType: "text/plain"
                                        invokeActionId: "bb.action.SHARE"
                                    }
                                    
                                    onTriggered: {
                                        console.log("UserEvent: ShareArabicOnly");
                                        data = persist.convertToUtf8(body.value);
                                    }
                                }
                            }
                        ]
                    }
                    
                    ImageView {
                        imageSource: "images/dividers/ayat_divider.png"
                        horizontalAlignment: HorizontalAlignment.Center
                        topMargin: 0; bottomMargin: 0
                    }
                    
                    Label
                    {
                        id: translation
                        property string value
                        multiline: true
                        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.fontSizeValue: helper.translationSize
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        
                        onValueChanged: {
                            text = value;
                        }
                        
                        contextActions: [
                            ActionSet
                            {
                                title: translation.value
                                
                                ActionItem
                                {
                                    title: qsTr("Copy") + Retranslate.onLanguageChanged
                                    imageSource: "images/menu/ic_copy.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: CopyTranslationOnly");
                                        persist.copyToClipboard(translation.value);
                                    }
                                }
                                
                                InvokeActionItem
                                {
                                    imageSource: "images/menu/ic_share.png"
                                    title: qsTr("Share") + Retranslate.onLanguageChanged
                                    
                                    query {
                                        mimeType: "text/plain"
                                        invokeActionId: "bb.action.SHARE"
                                    }
                                    
                                    onTriggered: {
                                        console.log("UserEvent: ShareTranslationOnly");
                                        data = persist.convertToUtf8(translation.value);
                                    }
                                }
                            }
                        ]
                    }
                    
                    gestureHandlers: [
                        FontSizePincher
                        {
                            key: "translationFontSize"
                            minValue: 4 ? 4 : 6
                            maxValue: 20 ? 20 : 30
                            userEventId: "PinchedTranslation"
                        }
                    ]
                }
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_ayat.png"
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}