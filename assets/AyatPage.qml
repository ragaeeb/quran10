import bb.cascades 1.2
import com.canadainc.data 1.0

Page
{
    property int surahId
    property int ayatId
    property variant similarVerses
    property variant explanations
    
    onSimilarVersesChanged: {
        if (similarNarrations.length > 0) {
            titleControl.addOption(similarOption);
        } else { // unlinked everything
            hadithOption.selected = true;
        }
    }
    
    onExplanationsChanged: {
        titleControl.addOption(tafsirOption);
    }
    
    onAyatIdChanged: {
        reload();
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchAyat)
        {
            if (data.length > 0)
            {
                notFound.delegateActive = false;
                
                var hadith = data[0];
                var english = helper.showTranslation;
                
                var collectionName = collections.renderAppropriate(hadith.collection);
                var reference = "(%1 #%2)".arg(collectionName).arg(hadith.hadithNumber);
                
                babName.subtitle = "%1:%2".arg(hadith.bookID).arg(hadith.inBookNumber);
                
                if (hadith.babNumber > 0) {
                    babName.title = "%1 %2".arg(hadith.babNumber).arg(english ? hadith.translated_chapter : hadith.arabic_chapter);
                }
                
                var bodyValue = hadith.arabic_text;
                
                if (english) {
                    bodyValue += "\n\n" + hadith.translated_text;
                }
                
                if (arabicId == 0 && data.length > 1) // we were invoked, and this is part of a series
                {
                    for (var i = 1; i < data.length; i++)
                    {
                        var nextHadith = data[i];
                        body += "\n\n" + nextHadith.arabic_text;
                        
                        if (english) {
                            bodyValue += "\n\n" + nextHadith.translated_text;
                        }
                    }
                }
                
                bodyValue += "\n\n"+reference;
                
                if (reporter.isAdmin) {
                    bodyValue = hadith.id+"\n\n"+bodyValue;
                }
                
                body.value = bodyValue;
                
                helper.fetchSimilarHadith(root, hadith.id);
                helper.fetchAllTafsirForHadith(root, hadith.id);
                helper.fetchHadithGrade(gradeLabel, hadith.id);
                helper.fetchBookName(root, hadith.collection, hadith.bookID);
                
                arabicId = hadith.id;
                collection = hadith.collection;
                hadithNumber = hadith.hadithNumber;
                busy.delegateActive = false;
            } else { // erroneous ID entered
                notFound.delegateActive = true;
                busy.delegateActive = false;
                console.log("Hadith not found!");
            }
        } else if (id == QueryId.FetchSimilarHadith && data.length > 0) {
            similarNarrations = data;
            if ( persist.tutorial( "tutorialSimilarHadith", qsTr("There appears to be other narrations with similar wording, choose the '%1 Similar' option at the top to view them in a split screen.").arg(data.length), "asset:///images/dropdown/similar.png" ) ) {}
        } else if (id == QueryId.FetchAllTafsirForHadith && data.length > 0) {
            explanations = data;
            if ( persist.tutorial( "tutorialTafsir", qsTr("There are explanations of this hadith by the people of knowledge! Tap on the '%1 Tafsir' option at the top to view them.").arg(data.length), "asset:///images/dropdown/tafsir.png" ) ) {}
        } else if (id == QueryId.FetchHadithContent && data.length > 0 && similarOption.selected) {
            pluginsDelegate.control.applyData(data);
        } else if (id == QueryId.FetchBookName && data.length > 0) {
            var bookTitle = helper.showTranslation ? data[0].translated_name : data[0].arabic_name;
            var collectionName = collections.renderAppropriate(collection);
            
            if (babName.title.length == 0) {
                babName.title = bookTitle.length == 0 ? collectionName : bookTitle;
            }
            
            if (bookTitle.length == 0) {
                bookTitle = collectionName;
            }
            
            hadithOption.text = bookTitle;
        }
    }
    
    function showExplanation(id)
    {
        definition.source = "HadithTafsirDialog.qml";
        var htd = definition.createObject();
        htd.suitePageId = id;
        htd.open();
    }
    
    function reload()
    {
        busy.delegateActive = true;
        
        if (ayatId > 0 && ayatId <= 286) {
            busy.delegateActive = true;
            helper.fetchHadith(root, arabicId);
        }
    }
    
    onCreationCompleted: {
        helper.textualChange.connect(reload);
    }
    
    titleBar: TitleBar
    {
        id: titleControl
        kind: TitleBarKind.Segmented
        options: [
            Option {
                id: hadithOption
                text: qsTr("Verse") + Retranslate.onLanguageChanged
                imageSource: "images/dropdown/original_hadith.png"
                
                onSelectedChanged: {
                    if (selected) {
                        console.log("UserEvent: HadithOptionSelected");
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
                text: similarNarrations ? qsTr("%n similar", "", similarNarrations.length) : ""
                imageSource: "images/dropdown/similar.png"
                
                onSelectedChanged: {
                    if (selected)
                    {
                        console.log("UserEvent: SimilarOptionSelected");
                        helper.fetchHadithContent(root, similarNarrations);
                        
                        pluginsDelegate.source = "SimilarHadithControl.qml";
                        pluginsDelegate.delegateActive = true;
                    }
                }
            },
            
            Option {
                id: tafsirOption
                text: explanations ? qsTr("%n tafsir", "", explanations.length) : ""
                imageSource: "images/dropdown/tafsir.png"
                
                onSelectedChanged: {
                    if (selected)
                    {
                        console.log("UserEvent: TafsirOptionSelected");
                        pluginsDelegate.source = "HadithTafsirPicker.qml";
                        pluginsDelegate.delegateActive = true;
                        
                        if (explanations.length == 1) {
                            showExplanation(explanations[0].id);
                        }
                    }
                }
            }
        ]
    }
    
    actions: [
        ActionItem {
            enabled: !notFound.delegateActive
            title: qsTr("Mark Favourite") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_bookmark_add.png"
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: BookmarkTriggered");
                
                shortcut.active = true;
                shortcut.object.bookmarkPrompt.show(); 
            }
        },
        
        ActionItem {
            enabled: !notFound.delegateActive
            title: qsTr("Add Shortcut") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_home_add.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Search
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: AddShortcutTriggered");
                
                shortcut.active = true;
                shortcut.object.homePrompt.show(); 
            }
        },
        
        ActionItem
        {
            title: qsTr("Copy") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_copy.png"
            
            onTriggered: {
                console.log("UserEvent: CopyHadith");
                persist.copyToClipboard(body.value)
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
                console.log("UserEvent: ShareHadithTriggered");
                data = persist.convertToUtf8(body.value);
            }
        },
        
        ActionItem
        {
            enabled: !notFound.delegateActive
            title: body.editable ? qsTr("Finish Editing") + Retranslate.onLanguageChanged : qsTr("Report Mistake") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_report_error.png"
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Edit
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: ReportMistakeActionTriggered");
                
                if (body.editable)
                {
                    definition.source = "ReportMistakeSheet.qml";
                    var sheet = definition.createObject();
                    sheet.body = body.value;
                    sheet.arabicId = arabicId;
                    sheet.expectedText = body.text;
                    sheet.open();
                    
                    body.editable = false;
                    body.text = body.value;
                } else {
                    body.editable = true;
                    persist.showBlockingToast( qsTr("The narration is now editable. Please make the changes you feel are needed to correct it and then from the menu choose 'Report Error' again."), qsTr("OK"), "asset:///images/menu/ic_report_error.png" );
                    body.requestFocus();
                }
            }
        }
    ]
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        background: bg.imagePaint
        
        layout: DockLayout {}
        
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
                        if ( persist.tutorial( "tutorialPinchHadith", qsTr("To increase and decrease the font size of the text simply do a pinch gesture here!"), "asset:///images/menu/ic_top.png" ) ) {}
                        else if ( persist.tutorial( "tutorialMarkFav", qsTr("To quickly access this hadith again, tap on the 'Mark Favourite' action at the bottom to put it in the Bookmarks tab that shows up in the start of the app."), "asset:///images/menu/ic_bookmark_add.png" ) ) {}
                        else if ( persist.tutorial( "tutorialAddShortcutHome", qsTr("To quickly access this hadith again, tap on the 'Add Shortcut' action at the bottom to pin it to your homescreen."), "asset:///images/menu/ic_home_add.png" ) ) {}
                        else if ( persist.tutorial( "tutorialShare", qsTr("To share this hadith with your friends tap on the 'Share' action at the bottom."), "asset:///images/menu/ic_share.png" ) ) {}
                        else if ( persist.tutorial( "tutorialLinkFromBook", qsTr("If you want to link this hadith to another, you can group them together by choosing the 'Link' action from the menu, then selecting the other narrations and tapping 'Save'! You will then find these hadith showing up in the 'Similar' tab at the top."), "asset:///images/menu/ic_link.png" ) ) {}
                        else if ( persist.tutorial( "tutorialReportMistake", qsTr("If you notice any mistakes with the text or the translation of the hadith, tap on the '...' icon at the bottom-right to use the menu, and use the 'Report Mistake' action from the menu."), "asset:///images/menu/ic_report_error.png" ) ) {}
                        else if ( persist.reviewed() ) {}
                        else if ( reporter.performCII() ) {}
                    }
                }
            ]
        }
        
        EmptyDelegate
        {
            id: notFound
            graphic: "images/placeholders/no_match.png"
            labelText: qsTr("The hadith was not found in the database.") + Retranslate.onLanguageChanged
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            ControlDelegate
            {
                id: pluginsDelegate
                topMargin: 0; bottomMargin: 0
                source: "HadithTafsirPicker.qml"
            }
            
            Header
            {
                id: babName
                
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
            
            ScrollView
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                gestureHandlers: [
                    PinchHandler
                    {
                        onPinchEnded: {
                            console.log("UserEvent: HadithPagePinched");
                            var newValue = Math.floor(event.pinchRatio*body.textStyle.fontSizeValue);
                            newValue = Math.max(6,newValue);
                            newValue = Math.min(newValue, 30);
                            
                            persist.saveValueFor("fontSize", newValue);
                            body.textStyle.fontSizeValue = newValue;
                        }
                    }
                ]
                
                TextArea
                {
                    id: body
                    property string value
                    backgroundVisible: false
                    content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                    editable: false
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: persist.getValueFor("fontSize")
                    //textStyle.base: collections.textFont
                    input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                    
                    onValueChanged: {
                        text = value;
                    }
                }
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/title/logo.png"
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        },
        
        ImagePaintDefinition {
            id: bg
            imageSource: "images/backgrounds/hadith_page_bg.png"
        },
        
        Delegate {
            id: shortcut
            active: false
            source: "ShortcutHelper.qml"
        }
    ]
}