import bb.cascades 1.0
import bb.system 1.0
import com.canadainc.data 1.0

Page
{
    id: narrationsPage
    property variant suitePageId
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onSuitePageIdChanged: {
        helper.fetchAyatsForTafsir(listView, suitePageId);
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(narrationsPage, listView);
    }
    
    actions: [
        ActionItem
        {
            id: addAction
            imageSource: "images/menu/ic_link_ayat_to_tafsir.png"
            title: qsTr("Add") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: TafsirAyatAddTriggered");
                prompt.inputField.resetDefaultText();
                prompt.resetIndexPath();
                prompt.show();
            }
        },
        
        ActionItem
        {
            id: searchAction
            imageSource: "images/menu/ic_search.png"
            title: qsTr("Search") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Search
                }
            ]
            
            function onPicked(chapter, verse)
            {
                navigationPane.pop();
                prompt.inputField.defaultText = chapter+":"+verse;
                prompt.show();
            }
            
            onTriggered: {
                console.log("UserEvent: LookupChapter");
                definition.source = "SearchPage.qml";
                var p = definition.createObject();
                p.picked.connect(onPicked);
                
                prompt.resetIndexPath();
                navigationPane.push(p);
            }
        },
        
        ActionItem
        {
            id: extractAyats
            imageSource: "images/menu/ic_capture_ayats.png"
            title: qsTr("Capture Ayats") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            function onDataLoaded(id, data)
            {
                if (id == QueryId.FetchTafsirContent)
                {
                    if (data.length > 0) {
                        admin.captureAyats(data[0].body);
                    } else {
                        busy.delegateActive = false;
                    }
                }
            }
            
            onTriggered: {
                console.log("UserEvent: ExtractHeadings");
                busy.delegateActive = true;
                helper.fetchTafsirContent(extractAyats, suitePageId);
            }
            
            function onCaptured(all)
            {
                if (all && all.length > 0) {
                    tafsirHelper.linkAyatsToTafsir(listView, suitePageId, all);
                    busy.delegateActive = true;
                } else {
                    persist.showToast( qsTr("No ayat signatures found..."), "", "asset:///images/menu/ic_capture_ayats.png" );
                    busy.delegateActive = false;
                }
            }
            
            onCreationCompleted: {
                admin.ayatsCaptured.connect(onCaptured);
            }
        }
    ]
    
    titleBar: TitleBar
    {
        title: qsTr("Ayats") + Retranslate.onLanguageChanged
        
        acceptAction: ActionItem
        {
			id: lookupAction
            imageSource: "images/dropdown/search_reference.png"
            title: qsTr("Picker") + Retranslate.onLanguageChanged
            
            function onPicked(chapter, verse)
            {
                navigationPane.pop();
                
                if (verse > 0) {
                    prompt.inputField.defaultText = chapter+":"+verse;
                } else {
                    prompt.inputField.defaultText = chapter+":";
                } 
                
                prompt.show();
            }
            
            onTriggered: {
                console.log("UserEvent: LookupChapter");
                definition.source = "SurahPickerPage.qml";
                
                prompt.resetIndexPath();
                var p = definition.createObject();
                p.picked.connect(onPicked);
                p.focusOnSearchBar = true;
                p.ready();
                
                navigationPane.push(p);
            }
        }
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        ListView
        {
            id: listView
            scrollRole: ScrollRole.Main
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            multiSelectHandler.actions: [
                DeleteActionItem
                {
                    imageSource: "images/menu/ic_unlink_tafsir_ayat.png"
                    title: qsTr("Unlink") + Retranslate.onLanguageChanged
                    
                    onTriggered: {
                        console.log("UserEvent: UnlinkAyatsFromTafsirTriggered");
                        
                        var all = listView.selectionList();
                        var ids = [];
                        
                        for (var i = all.length-1; i >= 0; i--) {
                            ids.push( adm.data(all[i]).id );
                        }
                        
                        helper.unlinkNarrationsForTafsir(listView, ids, suitePageId);
                        
                        for (var i = all.length-1; i >= 0; i--) {
                            adm.removeAt( all[i][0] );
                        }
                    }
                }
            ]
            
            function onDataLoaded(id, data)
            {
                if (id == QueryId.FetchAyatsForTafsir)
                {
                    if ( adm.isEmpty() )
                    {
                        if (data.length > 0) {
                            adm.append(data);
                        }
                    } else { // do diff
                        admin.doDiff(data, adm);
                        listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                    }
                } else if (id == QueryId.UnlinkAyatsFromTafsir) {
                    persist.showToast( qsTr("Ayat unlinked from tafsir"), "", "asset:///images/menu/ic_unlink_tafsir_ayat.png" );
                } else if (id == QueryId.LinkAyatsToTafsir) {
                    persist.showToast( qsTr("Ayat linked to tafsir!"), "", "asset:///images/menu/ic_link_ayat_to_tafsir.png" );
                    suitePageIdChanged();
                    
                    while (navigationPane.top != narrationsPage) {
                        navigationPane.pop();
                    }
                } else if (id == QueryId.UpdateTafsirLink) {
                    persist.showToast( qsTr("Ayat link updated"), "", "asset:///images/menu/ic_update_link.png" );
                }
                
                busy.delegateActive = false;
                listView.visible = !adm.isEmpty();
                noElements.delegateActive = !listView.visible;
            }
            
            onTriggered: {
                console.log("UserEvent: TafsirAyatTriggered");
                
				var d = dataModel.data(indexPath);
				definition.source = "AyatPage.qml";

				if (!d.from_verse_number) {
					definition.source = "SurahPage.qml";
				}
				
                var page = definition.createObject();
				
				if (d.from_verse_number) {
					page.surahId = d.surah_id;
					page.verseId = dataModel.data(indexPath).from_verse_number;
				} else {
					page.fromSurahId = d.surah_id;
					page.toSurahId = d.surah_id;
					prompt.indexPath = indexPath;
					page.picked.connect(lookupAction.onPicked);
				}
				
                navigationPane.push(page);
            }
            
            function updateLink(ListItem)
            {
                var chapter = ListItem.data.surah_id;
                var fromVerse = ListItem.data.from_verse_number;
                var toVerse = ListItem.data.to_verse_number;

                var defaultText = chapter+":";
                
                if (fromVerse > 0)
                {
                    defaultText += fromVerse;
                    
                    if (toVerse >= fromVerse) {
                        defaultText += "-"+toVerse;
                    }
                }
                
                prompt.indexPath = ListItem.indexPath;
                prompt.inputField.defaultText = defaultText;
                prompt.show();
            }
            
            function unlink(ListItem)
            {
                tafsirHelper.unlinkAyatsForTafsir(listView, [ListItem.data.id], suitePageId);
                adm.removeAt(ListItem.indexPath[0]);
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        id: rootItem
                        description: ListItemData.from_verse_number+"-"+ListItemData.to_verse_number
                        imageSource: "images/list/ic_tafsir_ayat.png"
                        title: ListItemData.surah_id
                        status: ListItemData.id
                        
                        contextActions: [
                            ActionSet
                            {
                                title: rootItem.id
                                subtitle: rootItem.status
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_update_link.png"
                                    title: qsTr("Edit") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: UpdateAyatTafsirLink");
                                        rootItem.ListItem.view.updateLink(rootItem.ListItem);
                                    }
                                }
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_unlink_tafsir_ayat.png"
                                    title: qsTr("Unlink") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: UnlinkAyatFromTafsir");
                                        rootItem.ListItem.view.unlink(rootItem.ListItem);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
        }
        
        EmptyDelegate
        {
            id: noElements
            graphic: "images/placeholders/empty_suite_ayats.png"
            labelText: qsTr("No ayats linked. Tap on the Add button to add a new one.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                addAction.triggered();
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_suite_ayats.png"
        }
    }
    
    attachedObjects: [
        SystemPrompt
        {
            id: prompt
            property variant indexPath
            body: qsTr("Enter the chapter and verse associated with this tafsir:") + Retranslate.onLanguageChanged
            inputField.inputMode: SystemUiInputMode.NumbersAndPunctuation
            inputField.emptyText: qsTr("(ie: 2:4 for Surah Baqara verse #4)") + Retranslate.onLanguageChanged
            inputField.maximumLength: 12
            title: qsTr("Enter verse") + Retranslate.onLanguageChanged
            
            function resetIndexPath() {
                indexPath = undefined;
            }
            
            onFinished: {
                if (value == SystemUiResult.ConfirmButtonSelection)
                {
                    var inputted = inputFieldTextEntry().trim();
                    var tokens = inputted.split(":");
                    var chapter = parseInt(tokens[0]);
                    
                    if (chapter > 0)
                    {
                        var fromVerse = 0;
                        var toVerse = 0;
                        
                        if (tokens.length > 1)
                        {
                            tokens = tokens[1].split("-");
                            
                            fromVerse = parseInt(tokens[0]);
                            
                            if (tokens.length > 1) {
                                toVerse = parseInt(tokens[1]);
                            } else {
                                toVerse = fromVerse;
                            }
                        }
                        
                        if (indexPath)
                        {
                            var current = adm.data(indexPath);
                            current.surah_id = chapter;
                            current.from_verse_number = fromVerse;
                            current.to_verse_number = toVerse;
                            
                            tafsirHelper.updateTafsirLink(listView, current.id, chapter, fromVerse, toVerse);
                            adm.replace(indexPath[0], current);
                        } else {
                            tafsirHelper.linkAyatToTafsir(listView, suitePageId, chapter, fromVerse, toVerse);
                        }
                    } else {
                        persist.showToast( qsTr("Invalid entry specified. Please enter something with the Chapter:Verse scheme (ie: 2:55 for Surah Baqara vese #55)"), "", "asset:///images/toast/invalid_entry.png" );
                    }
                }
            }
        }
    ]
}