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
            imageSource: "images/menu/ic_add.png"
            title: qsTr("Add") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: TafsirNarrationAddTriggered");
                definition.source = "SearchPickerPage.qml";
                var page = definition.createObject();
                page.narrationsSelected.connect(onNarrationsSelected);
                
                navigationPane.push(page);
            }
        }
    ]
    
    ListView
    {
        id: listView
        
        dataModel: ArrayDataModel {
            id: adm
        }
        
        multiSelectHandler.actions: [
            DeleteActionItem
            {
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
                adm.clear();
                adm.append(data);
                
                if ( adm.isEmpty() ) {
                    addAction.triggered();
                }
            } else if (id == QueryId.UnlinkNarrationForTafsir) {
                persist.showToast( qsTr("Narration unlinked from tafsir"), "", "file:///usr/share/icons/bb_action_delete.png" );
            } else if (id == QueryId.LinkNarrationsToTafsir) {
                persist.showToast( qsTr("Narration linked to tafsir!"), "", "asset:///images/menu/ic_add.png" );
                suitePageIdChanged();
                
                while (navigationPane.top != narrationsPage) {
                    navigationPane.pop();
                }
            } else if (id == QueryId.FetchSimilarHadith) {
                var ids = prompt.arabicIds;
                
                for (var i = data.length-1; i >= 0; i--) {
                    ids.push(data[i].id);
                }
                
                helper.linkNarrationsToTafsir(listView, suitePageId, ids);
            }
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
            helper.unlinkNarrationsForTafsir(listView, [ListItemData.id], suitePageId);
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
                                title: qsTr("Unlink") + Retranslate.onLanguageChanged
                                
                                onTriggered: {
                                    console.log("UserEvent: UnlinkNarrationFromTafsirTriggered");
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
}