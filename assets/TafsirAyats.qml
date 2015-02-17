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
        deviceUtils.attachTopBottomKeys(narrationsPage, listView, true);
    }
    
    actions: [
        ActionItem
        {
            id: addAction
            imageSource: "images/menu/ic_link_ayat_to_tafsir.png"
            title: qsTr("Add") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: TafsirAyatAddTriggered");
                prompt.show();
            }
        }
    ]
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        ListView
        {
            id: listView
            
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
                        } else {
                            addAction.triggered();
                        }
                    } else { // do diff
                        app.doDiff(data, adm);
                    }
                } else if (id == QueryId.UnlinkAyatsFromTafsir) {
                    persist.showToast( qsTr("Ayat unlinked from tafsir"), "", "asset:///images/menu/ic_unlink_tafsir_ayat.png" );
                } else if (id == QueryId.LinkAyatsToTafsir) {
                    persist.showToast( qsTr("Ayat linked to tafsir!"), "", "asset:///images/menu/ic_link_ayat_to_tafsir.png" );
                    suitePageIdChanged();
                    
                    while (navigationPane.top != narrationsPage) {
                        navigationPane.pop();
                    }
                }
                
                busy.delegateActive = false;
                listView.visible = !adm.isEmpty();
                noElements.delegateActive = !listView.visible;
            }
            
            onTriggered: {
                console.log("UserEvent: TafsirAyatTriggered");
                
                definition.source = "AyatPage.qml";
                var page = definition.createObject();
                page.surahId = dataModel.data(indexPath).surah_id;
                page.verseId = dataModel.data(indexPath).verse_id;
                
                navigationPane.push(page);
            }
            
            function unlink(ListItemData) {
                helper.unlinkAyatsForTafsir(listView, [ListItemData.id], suitePageId);
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    Container
                    {
                        id: rootItem
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        background: ListItem.selected ? Color.DarkGray : undefined
                        
                        Header {
                            id: header
                            title: ListItemData.name
                            subtitle: "%1:%2".arg(ListItemData.surah_id).arg(ListItemData.verse_id)
                        }
                        
                        Label
                        {
                            id: body
                            multiline: true
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            text: ListItemData.content
                        }
                        
                        contextActions: [
                            ActionSet {
                                title: header.title
                                subtitle: header.subtitle
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_unlink_tafsir_ayat.png"
                                    title: qsTr("Unlink") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: UnlinkNarrationFromTafsir");
                                        rootItem.ListItem.view.unlink(ListItemData);
                                        rootItem.ListItem.view.dataModel.removeAt(rootItem.ListItem.indexPath[0]);
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
            asset: "images/progress/loading_suite_pages.png"
        }
    }
    
    attachedObjects: [
        SystemPrompt
        {
            id: prompt
            body: qsTr("Enter the chapter and verse associated with this tafsir:") + Retranslate.onLanguageChanged
            inputField.inputMode: SystemUiInputMode.NumbersAndPunctuation
            inputField.emptyText: qsTr("(ie: 2:4 for Surah Baqara verse #4)") + Retranslate.onLanguageChanged
            inputField.maximumLength: 9
            title: qsTr("Enter verse") + Retranslate.onLanguageChanged
            
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
                        
                        helper.linkAyatToTafsir(listView, suitePageId, chapter, fromVerse, toVerse);
                    } else {
                        persist.showToast( qsTr("Invalid entry specified. Please enter something with the Chapter:Verse scheme (ie: 2:55 for Surah Baqara vese #55)"), "", "asset:///images/toast/invalid_entry.png" );
                    }
                }
            }
        }
    ]
}