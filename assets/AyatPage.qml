import bb.cascades 1.2
import bb.system 1.0
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
                    similarOption.similarCount = n;
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
        } else if (id == QueryId.FetchSimilarAyatContent && data.length > 0 && similarOption.selected) {
            pluginsDelegate.control.applyData(data, helper.showTranslation ? translation : body);
        } else if (id == QueryId.FetchSurahHeader && data.length > 0) {
            ayatOption.text = data[0].translation ? data[0].translation : data[0].name;
            babName.title = data[0].transliteration ? data[0].transliteration : data[0].name;
            babName.subtitle = "%1:%2".arg(surahId).arg(verseId);
            
            translation.value = translation.value + "\n\n(" + babName.title + " " + babName.subtitle + ")";
        } else if (id == QueryId.SaveBookmark) {
            persist.showToast( qsTr("Favourite added for Chapter %1, Verse %2").arg(surahId).arg(verseId), "images/menu/ic_bookmark_add.png" );
            bookmarkHelper.bookmarksUpdated();
        } else if (id == QueryId.FetchTransliteration) {
            transliteration.text = data[0].html;
        } else if (id == QueryId.FetchAdjacentAyat) {
            if (data.length > 0) {
                surahId = data[0].surah_id;
                verseId = data[0].verse_id;
            } else {
                notification.init( qsTr("Ayat not found"), "images/toast/ic_no_ayat_found.png" );
            }
        }
    }
    
    function showExplanation(id)
    {
        var htd = Qt.initQml("AyatTafsirDialog.qml");
        htd.suitePageId = id;
        htd.open();
    }
    
    function reload()
    {
        if (surahId > 0 && verseId > 0)
        {
            transliteration.resetText();
            body.value = "";
            body.resetText();
            
            translation.value = "";
            translation.resetText();
            
            titleControl.removeOption(similarOption);
            titleControl.removeOption(tafsirOption);
            ayatOption.selected = true;
            
            busy.delegateActive = true;
            helper.fetchAyat(root, surahId, verseId);
        }
    }
    
    function shift(i)
    {
        helper.fetchAdjacentAyat(root, surahId, verseId, i);
        titleControl.selectedOption = ayatOption;
        titleControl.removeOption(similarOption);
        titleControl.removeOption(tafsirOption);
        
        reporter.record("ShiftAyat", surahId+":"+verseId+","+i);
    }
    
    onActionMenuVisualStateChanged: {
        if (actionMenuVisualState == ActionMenuVisualState.VisibleFull)
        {
            tutorial.execOverFlow( "nextVerse", qsTr("Tap on the '%1' action to go to the verse after this one in the Qu'ran."), nextVerse );
            tutorial.execOverFlow( "prevVerse", qsTr("Tap on the '%1' action to go to the verse before this one in the Qu'ran."), prevVerse );
        }
        
        reporter.record("AyatPageMenuOpened", actionMenuVisualState.toString());
    }
    
    function cleanUp()
    {
        helper.textualChange.disconnect(reload);
        app.lazyInitComplete.disconnect(showTutorials);
        Qt.navigationPane.pushTransitionEnded.disconnect(showTutorials);
    }
    
    function showTutorials()
    {
        app.lazyInitComplete.disconnect(showTutorials);
        Qt.navigationPane.pushTransitionEnded.disconnect(showTutorials);
        
        tutorial.execActionBar( "markFav", qsTr("To quickly access this verse again, tap on the '%1' action at the bottom to put it in the Favourites tab.").arg(markFav.title) );
        tutorial.execActionBar( "addShortcutHome", qsTr("To quickly access this verse again, tap on the '%1' action at the bottom to pin it to your homescreen.").arg(addHome.title), "l" );
        tutorial.execActionBar( "share", qsTr("To share this verse with your friends tap on the '%1' action at the bottom.").arg(shareAction.title), "r" );
        tutorial.exec( "lpArabic", qsTr("Press-and-hold on the arabic text if you want to copy or share it."), HorizontalAlignment.Right, VerticalAlignment.Top, 0, tutorial.du(2), tutorial.du(21));
        
        if (tafsirOption.tafsirCount > 0 && similarOption.similarCount > 0)
        {
            tutorial.execTitle( "tafsir", qsTr("There are explanations of this verse by the people of knowledge! Tap on the '%1' option at the top to view them.").arg(tafsirOption.text), "r");
            tutorial.exec( "similarAyat", qsTr("There appears to be other verses with similar wording, choose the '%1' option at the top to view them in a split screen.").arg(similarOption.text), HorizontalAlignment.Center, VerticalAlignment.Top, tutorial.du(16), 0, tutorial.du(4));
            tutorial.exec( "ayatAudio", qsTr("Tap on the '%1' option to listen to this verse over and over in isolation.").arg(recitationOption.text), HorizontalAlignment.Center, VerticalAlignment.Top, 0, tutorial.du(24), tutorial.du(4));
        }
        
        if (body.text.length > 0)
        {
            tutorial.execCentered( "arabicZoom", qsTr("Do a pinch gesture on the arabic text to increase or decrease the size of the font!"), "images/common/pinch.png" );
            tutorial.exec( "transliteration", qsTr("Tap on the arabic text to show the transliteration."), HorizontalAlignment.Right, VerticalAlignment.Top, 0, tutorial.du(2), tutorial.du(21));
        }
        
        if (helper.showTranslation) {
            tutorial.exec( "translationZoom", qsTr("Do a pinch gesture on the translation text to increase or decrease the size of the font!"), HorizontalAlignment.Center, VerticalAlignment.Center, 0, 0, 0, tutorial.du(10), "images/common/pinch.png" );
            tutorial.exec( "lpTranslation", qsTr("Press-and-hold on the translation text if you want to copy or share it."), HorizontalAlignment.Left, VerticalAlignment.Center, 0, 0, tutorial.du(36));
        }
        
        reporter.record("AyatOpened", surahId+":"+verseId);
    }
    
    onCreationCompleted: {
        helper.textualChange.connect(reload);
        app.lazyInitComplete.connect(showTutorials);
        Qt.navigationPane.pushTransitionEnded.connect(showTutorials);
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
                value: "ayatOption"
                
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
                value: "recitationOption"
                
                onSelectedChanged: {
                    if (selected)
                    {
                        console.log("UserEvent: RecitationOptionSelected");
                        pluginsDelegate.source = "RecitationControl.qml";
                        pluginsDelegate.delegateActive = true;
                        
                        reporter.record("OpenAyatRecitation", surahId+":"+verseId);
                    } else if (pluginsDelegate.control) {
                        pluginsDelegate.control.cleanUp();
                    }
                }
            }
        ]
        
        attachedObjects: [
            Option {
                id: similarOption
                property int similarCount
                imageSource: "images/dropdown/similar.png"
                text: qsTr("%n similar", "", similarCount) + Retranslate.onLanguageChanged
                value: "similarOption"
                
                onSelectedChanged: {
                    if (selected)
                    {
                        console.log("UserEvent: SimilarOptionSelected");
                        helper.fetchSimilarAyatContent(root, surahId, verseId);
                        
                        pluginsDelegate.source = "SimilarAyatControl.qml";
                        pluginsDelegate.delegateActive = true;
                        
                        reporter.record("OpenAyatSimilar", surahId+":"+verseId);
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
                value: "tafsirOption"
                
                onSelectedChanged: {
                    if (selected)
                    {
                        console.log("UserEvent: TafsirOptionSelected");
                        pluginsDelegate.source = "AyatTafsirPicker.qml";
                        pluginsDelegate.delegateActive = true;
                        
                        reporter.record("OpenAyatTafsir", surahId+":"+verseId);
                    }
                }
            }
        ]
    }
    
    actions: [
        ActionItem
        {
            id: markFav
            enabled: !notFound.delegateActive
            title: qsTr("Mark Favourite") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_mark_favourite.png"
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            function onTagEntered(tag, name)
            {
                bookmarkHelper.saveBookmark(root, surahId, verseId, name, tag);
                reporter.record("MarkFavourite", surahId+":"+verseId);
                reporter.record("FavouriteTag", tag);
            }
            
            function onFinished(name)
            {
                if (name.length > 0) {
                    persist.showPrompt( markFav, qsTr("Enter tag"), qsTr("You can use this to categorize related verses together."), "", qsTr("Enter a tag for this bookmark (ie: ramadan). You can leave this blank if you don't want to use a tag."), 50, "onTagEntered", name );
                }
            }
            
            onTriggered: {
                console.log("UserEvent: MarkFavourite");
                persist.showPrompt( markFav, qsTr("Enter name"), qsTr("You can use this to quickly recognize this ayah in the favourites tab."), translation.value, qsTr("Name..."), 50 );
            }
        },
        
        ActionItem
        {
            id: addHome
            enabled: !notFound.delegateActive
            title: qsTr("Add Shortcut") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_home.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Search
                }
            ]
            
            function onFinished(name)
            {
                if (name.length > 0)
                {
                    offloader.addToHomeScreen(surahId, verseId, name);
                    reporter.record("AddAyatShortcut", surahId+":"+verseId);
                }
            }
            
            onTriggered: {
                console.log("UserEvent: AddShortcutTriggered");
                persist.showPrompt( addHome, qsTr("Enter name"), qsTr("You can use this to quickly recognize this ayah on your home screen."), translation.value, qsTr("Name..."), 15, "onFinished" );
            }
        },
        
        ActionItem
        {
            id: copyAction
            title: qsTr("Copy") + Retranslate.onLanguageChanged
            imageSource: "images/common/ic_copy.png"
            
            onTriggered: {
                console.log("UserEvent: CopyAyat");
                persist.copyToClipboard(body.value+"\n\n"+translation.value);
                reporter.record("CopyAyat", surahId+":"+verseId);
            }
        },
        
        InvokeActionItem
        {
            id: shareAction
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
                reporter.record("ShareAyat", surahId+":"+verseId);
            }
        },
        
        ActionItem
        {
            id: prevVerse
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
                    
                    onTriggered: {
                        reporter.record("PrevAyatShortcut", surahId+":"+verseId);
                    }
                }
            ]
        },
        
        ActionItem
        {
            id: nextVerse
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
                    
                    onTriggered: {
                        reporter.record("NextAyatShortcut", surahId+":"+verseId);
                    }
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
                                reporter.record("AyatHeaderTapped", surahId+":"+verseId);
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
                            
                            onEnded: {
                                tutorial.exec( "transliterationWarning", qsTr("Please note that the scholars have mentioned to avoid the transliteration option since when depended upon it may introduce many mistakes because it cannot capture the Arabic pronunciations and rules properly.\n\nPlease use the Audio option to play the verse, and only use the transliteration text as a tool to help you, and do not depend on it fully."), HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, tutorial.du(18) );
                            }
                        }
                    ]
                }
            }
            
            ScrollView
            {
                id: sv
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                gestureHandlers: [
                    PinchHandler
                    {
                        onPinchStarted: {
                            sv.scrollViewProperties.scrollMode = ScrollMode.None; // this hack is needed due to a bug in 10.3 OS, pinch gestures are not detected on the labels unless the scrollmode is set to none 
                        }
                        
                        onPinchEnded: {
                            sv.scrollViewProperties.scrollMode = ScrollMode.Vertical;
                        }
                    }
                ]
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    leftPadding: tutorial.du(1)
                    rightPadding: tutorial.du(1)
                    
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
                                    
                                    if (!transliteration.visible && helper.showTranslation) {
                                        helper.fetchTransliteration(root, surahId, verseId);
                                    }
                                    
                                    reporter.record("TappedAyatArabic", surahId+":"+verseId);
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
                                title: body.value
                                
                                ActionItem
                                {
                                    title: qsTr("Copy") + Retranslate.onLanguageChanged
                                    imageSource: "images/common/ic_copy.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: CopyArabicOnly");
                                        persist.copyToClipboard(body.value);
                                        
                                        reporter.record("CopyArabicOnly", surahId+":"+verseId);
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
                                        
                                        reporter.record("ShareArabicOnly", surahId+":"+verseId);
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
                                    imageSource: "images/common/ic_copy.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: CopyTranslationOnly");
                                        persist.copyToClipboard(translation.value);
                                        
                                        reporter.record("CopyTranslationOnly", surahId+":"+verseId);
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
                                        
                                        reporter.record("ShareTranslationOnly", surahId+":"+verseId);
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
}