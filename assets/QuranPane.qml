import bb.cascades 1.2
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);

        if ( tutorial.promptVideo("http://youtu.be/YOXtjnNWVZM") ) {}
        else if ( tutorial.showAd("markazAlHikmah", "Markaz", qsTr("Learn Qur'an & Arabic!"), "http://canadainc.org/hosting/alfurqan/al_furqan_logo.jpg", "56E8A18A", "http://instagram.com/MarkazAlHikmah", "admin@markazalhikmah.net", "https://www.facebook.com/profile.php?id=100010470699798", "https://twitter.com/markazalhikmah", 20) ) {}
    }
    
    function onAyatPicked(surahId, verseId)
    {
        definition.source = "AyatPage.qml";
        var ayatPage = definition.createObject();
        ayatPage.surahId = surahId;
        ayatPage.verseId = verseId;
        
        navigationPane.push(ayatPage);
    }
    
    function onOpenChapter(surahId)
    {
        definition.source = "ChapterTafsirPicker.qml";
        var p = definition.createObject();
        p.chapterNumber = surahId;
        
        navigationPane.push(p);
    }
    
    SurahPickerPage
    {
        id: pickerPage
        showJuz: true

        titleBarSpace: Button
        {
            id: buttonControl
            property variant progressData
            text: progressData ? progressData.surah_id+":"+progressData.verse_id : ""
            imageSource: "images/dropdown/saved_bookmark.png"
            verticalAlignment: VerticalAlignment.Center
            maxWidth: tutorial.du(18.75)
            translationX: -250
            scaleX: 1.1
            scaleY: 1.1
            visible: false
            
            onClicked: {
                console.log("UserEvent: SavedBookmarkClicked");
                pickerPage.picked(progressData.surah_id, progressData.verse_id);
            }
            
            onVisibleChanged: {
                if ( visible && tutorial.isTopPane(navigationPane, pickerPage) ) {
                    tutorial.exec( "bookmarkAnchor", qsTr("Notice the button on the top left. This is used to track your Qu'ran reading progress. You can use it to quickly jump to the verse you last left off."), HorizontalAlignment.Left, VerticalAlignment.Top, tutorial.du(2), 0, tutorial.du(4) );
                }
                
                if (visible && scaleX != 1) {
                    rotator.play();
                }
            }
            
            function onDataLoaded(id, data)
            {
                if (id == QueryId.FetchLastProgress)
                {
                    if (data.length > 0)
                    {
                        buttonControl.progressData = data[0];
                        buttonControl.visible = true;
                    } else if ( persist.contains("bookmarks") ) {
                        bookmarkHelper.saveLegacyBookmarks( buttonControl, persist.getValueFor("bookmarks") );
                    }
                } else if (id == QueryId.SaveLegacyBookmarks) {
                    persist.remove("bookmarks");
                    persist.showToast( qsTr("Ported legacy bookmarks!"), "asset:///images/menu/ic_bookmark_add.png");
                }
            }
            
            function onLastPositionUpdated() {
                bookmarkHelper.fetchLastProgress(buttonControl);
            }
            
            contextActions: [
                ActionSet {
                    title: buttonControl.text
                    subtitle: buttonControl.progressData ? Qt.formatDateTime(buttonControl.progressData.timestamp) : ""
                }
            ]
            
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
                        duration: 750
                        easingCurve: StockCurve.DoubleElasticOut
                    }
                }
            ]
        }

        pickerList.onSelectionChanged: {
            if (sortValue == "juz" && indexPath.length == 1) { // don't allow selection of headers
                pickerList.select(indexPath, false);
            } else {
                var all = pickerList.selectionList();
                var n = all.length;
                compareAction.enabled = n > 1 && n < 5;
                openAction.enabled = n > 0 && (sortValue == "juz" || sortValue == "normal");
                pickerList.multiSelectHandler.status = qsTr("%n chapters selected", "", n);
            }
        }
        
        pickerList.multiSelectAction: MultiSelectActionItem {
            imageSource: "images/menu/ic_select_more_chapters.png"
        }
        
        pickerList.multiSelectHandler.onActiveChanged: {
            if (!active) {
                pickerList.clearSelection();
            } else {
                tutorial.execActionBar("compare", qsTr("Use the '%1' action to compare two or more surahs side by side. A maximum of 4 surahs may be compared at once.").arg(compareAction.title), "l" );
                tutorial.execActionBar("openRange", qsTr("Use the '%1' action to open all the surah between the first selection and the last selection.").arg(openAction.title), "r");
                
                if (!openAction.enabled) {
                    tutorial.execActionBar("openRangeDisabled", qsTr("Note that the '%1' action is only available in the 'Normal' and 'Juz' display modes.").arg(openAction.title), "r");
                }
            }
        }

        pickerList.multiSelectHandler.actions: [
            ActionItem
            {
                id: compareAction
                enabled: false
                imageSource: "images/menu/ic_compare.png"
                title: qsTr("Compare") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: CompareSurahs");
                    definition.source = "CompareSurahsPage.qml";
                    var p = definition.createObject();
                    
                    var all = pickerPage.pickerList.selectionList();
                    var surahIds = [];
                    
                    for (var i = all.length-1; i >= 0; i--) {
                        surahIds.push( pickerPage.pickerList.dataModel.data(all[i]).surah_id );
                    }
                    
                    p.surahIds = surahIds;
                    navigationPane.push(p);
                    
                    reporter.record("CompareSurahs", surahIds.toString());
                }
            },
            
            ActionItem
            {
                id: openAction
                enabled: false
                imageSource: "images/menu/ic_open_range.png"
                title: qsTr("Open Range") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: OpenSurahs");
                    definition.source = "SurahPage.qml";
                    var p = definition.createObject();
                    p.picked.connect(onAyatPicked);
                    p.openChapterTafsir.connect(onOpenChapter);
                    
                    var all = pickerPage.pickerList.selectionList();
                    p.fromSurahId = pickerPage.pickerList.dataModel.data(all[0]).surah_id;
                    p.toSurahId = pickerPage.pickerList.dataModel.data(all[all.length-1]).surah_id;
                    p.loadAyats();
                    navigationPane.push(p);
                    
                    reporter.record("OpenSurahs", p.fromSurahId+"-"+p.toSurahId);
                }
            }
        ]
        
        actions: [
            ActionItem {
                title: qsTr("Mushaf") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_mushaf.png"
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: LaunchMushaf");
                    definition.source = "MushafSheet.qml";
                    var sheet = definition.createObject();
                    sheet.open();
                    
                    reporter.record("LaunchMushaf");
                }
                
                shortcuts: [
                    Shortcut {
                        key: qsTr("M") + Retranslate.onLanguageChanged
                    }
                ]
            },
            
            ActionItem
            {
                id: selectAll
                title: qsTr("Select All") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_select_all.png"
                enabled: pickerPage.sortValue != "juz"
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: SelectAllSurahs");
                    pickerPage.pickerList.multiSelectHandler.active = true;
                    pickerPage.pickerList.selectAll();
                    
                    reporter.record("SelectAllSurahs");
                }
                
                shortcuts: [
                    Shortcut {
                        key: qsTr("A") + Retranslate.onLanguageChanged
                    }
                ]
            }
        ]
        
        function createAndAttach(p)
        {
            definition.source = p;
            var surahPage = definition.createObject();
            surahPage.picked.connect(onAyatPicked);
            surahPage.openChapterTafsir.connect(onOpenChapter);
            
            navigationPane.push(surahPage);
            
            return surahPage;
        }
        
        onJuzPicked: {
            var surahPage = createAndAttach("JuzPage.qml");
            surahPage.juzId = juzId;
        }
        
        onPicked: {
            var surahPage = createAndAttach("SurahPage.qml");
            surahPage.surahId = chapter;
            surahPage.verseId = verse;
        }
        
        function onDataLoaded(id, data)
        {
            if (id == QueryId.FetchRandomQuote && data.length > 0)
            {
                var quote = data[0];
                
                if (quote.hidden != 1)
                {
                    var plainText = "“%1” - %2 [%3]".arg(quote.body).arg(quote.author).arg(quote.reference);
                    var body = "<html><i>“%1”</i>\n\n- <b>%2%4</b>\n\n[%3]</html>".arg( quote.body.replace(/&/g,"&amp;") ).arg(quote.author).arg( quote.reference.replace(/&/g,"&amp;") ).arg( global.getSuffix(quote.birth, quote.death, quote.is_companion == 1, quote.female == 1) );
                    notification.init(body, "images/list/ic_quote.png", plainText);
                } else {
                    console.log("QuoteSuppressed");
                }
            }
        }
    }
    
    function onLazyInitComplete()
    {
        pickerPage.ready();
        
        tutorial.execActionBar( "openMushaf", qsTr("Tap here to open the mushaf!") );
        tutorial.execActionBar("selectAllSurahs", qsTr("Tap on the '%1' action to view the entire Qu'ran (all the surahs)!").arg(selectAll.title), "r");
        var noMoreTutorialsLeft = tutorial.exec("lpSurahPicker", "Press and hold on a surah for a menu to select multiple chapters.", HorizontalAlignment.Center, VerticalAlignment.Center, tutorial.du(2), 0, 0, tutorial.du(2));
        
        if ( !noMoreTutorialsLeft && persist.getValueFor("hideRandomQuote") != 1 ) {
            helper.fetchRandomQuote(pickerPage);
        }
        
        buttonControl.onLastPositionUpdated();
        global.lastPositionUpdated.connect(buttonControl.onLastPositionUpdated);
        
        if (!selectAll.enabled) {
            tutorial.execActionBar("selectAllDisabled", qsTr("The '%1' feature is not available for the Juz display mode.").arg(selectAll.title), "r");
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}