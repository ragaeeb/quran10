import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();
/*        
        if ( persist.tutorialVideo("http://youtu.be/7nA27gIxZ08") ) {}
        else if ( tutorialToast.tutorial( "tutorialAlphanumeric", qsTr("Did you know you can quickly jump to a specific verse by typing its chapter number followed by a ':' and followed by the verse number.\n\nFor example, to jump to Surah Al-Baqara Verse #2, type '2:2' into the search field!"), "images/ic_quran.png" ) ) {}
        else if ( !persist.contains("alFurqanAdvertised") ) {
            definition.source = "AlFurqanAdvertisement.qml";
            var advertisement = definition.createObject();
            advertisement.open();
            persist.saveValueFor("alFurqanAdvertised", 1, false);
        } */
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

        pickerList.onSelectionChanged: {
            if (sortValue == "juz" && indexPath.length == 1) { // don't allow selection of headers
                pickerList.select(indexPath, false);
            } else {
                var all = pickerList.selectionList();
                var n = all.length;
                compareAction.enabled = n > 1 && n < 5;
                openAction.enabled = n > 0;
                pickerList.multiSelectHandler.status = qsTr("%n chapters selected", "", n);
            }
        }
        
        pickerList.multiSelectAction: MultiSelectActionItem {
            imageSource: "images/menu/ic_select_more_chapters.png"
        }
        
        pickerList.multiSelectHandler.onActiveChanged: {
            if (!active) {
                pickerList.clearSelection();
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
                    navigationPane.push(p);
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
                }
                
                shortcuts: [
                    Shortcut {
                        key: qsTr("M") + Retranslate.onLanguageChanged
                    }
                ]
            },
            
            ActionItem {
                title: qsTr("Select All") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_select_all.png"
                enabled: pickerPage.sortValue != "juz"
                
                onTriggered: {
                    console.log("UserEvent: SelectAll");
                    pickerPage.pickerList.multiSelectHandler.active = true;
                    pickerPage.pickerList.selectAll();
                }
                
                shortcuts: [
                    Shortcut {
                        key: qsTr("A") + Retranslate.onLanguageChanged
                    }
                ]
            }
        ]
        
        onJuzPicked: {
            definition.source = "JuzPage.qml";
            var surahPage = definition.createObject();
            navigationPane.push(surahPage);
            
            surahPage.juzId = juzId;
        }
        
        onPicked: {
            definition.source = "SurahPage.qml";
            var surahPage = definition.createObject();
            surahPage.picked.connect(onAyatPicked);
            surahPage.openChapterTafsir.connect(onOpenChapter);
            
            navigationPane.push(surahPage);
            
            surahPage.fromSurahId = chapter;
            surahPage.toSurahId = chapter;
            surahPage.requestedVerse = verse;
        }
        
        function onDataLoaded(id, data)
        {
            if (id == QueryId.FetchRandomQuote && data.length > 0)
            {
                console.log("*** SDLKFJ");
                var quote = data[0];
                console.log("*** SDLKFJ33");
                var body = qsTr("<html><i>“%1”</i>\n\n- <b>%2%4</b>\n\n[%3]\n\n\n</html>").arg(quote.body).arg(quote.displayName ? quote.displayName : quote.author).arg(quote.reference).arg( global.getSuffix(quote.birth, quote.death, quote.companion_id, quote.female == 1) );
                console.log("*** SDLKFJ222");
                tutorialToast.init(body, "images/ic_quran.png");
                console.log("*** SDLKFJxxx");
            }
        }
        
        function onLazyInitComplete()
        {
            ready();
            helper.fetchRandomQuote(pickerPage);
        }
        
        onCreationCompleted: {
            app.lazyInitComplete.connect(onLazyInitComplete);
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}