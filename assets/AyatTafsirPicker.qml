import bb.cascades 1.0
import com.canadainc.data 1.0

ResizableContainer
{
    headerTitle: qsTr("Explanations") + Retranslate.onLanguageChanged
    
    onCreationCompleted: {
        helper.fetchAllTafsirForAyat(tafsirList, root.surahId, root.verseId);
    }
    
    ListView
    {
        id: tafsirList
        maxHeight: screenHeight*ratio
        
        function onDataLoaded(id, data)
        {
            if (id == QueryId.FetchTafsirForAyat)
            {
                adm.append(data);
                
                if (data.length == 1) {
                    showExplanation(data[0].id);
                }
                
                headerSubtitle = data.length;
            }
        }
        
        function addToHomeScreen(ListItemData)
        {
            shortcut.active = true;
            shortcut.object.homeTafsirPrompt.suitePageId = ListItemData.id;
            shortcut.object.homeTafsirPrompt.inputField.defaultText = ListItemData.title;
            shortcut.object.homeTafsirPrompt.show();
        }
        
        onTriggered: {
            console.log("UserEvent: TafsirTriggered");
            showExplanation( dataModel.data(indexPath).id );
        }
        
        dataModel: ArrayDataModel {
            id: adm
        }
        
        listItemComponents: [
            ListItemComponent
            {
                StandardListItem
                {
                    id: rootItem
                    title: ListItem.data.author
                    description: ListItem.data.title
                    imageSource: "images/list/ic_tafsir.png"
                    
                    contextActions: [
                        ActionSet
                        {
                            title: rootItem.title
                            subtitle: rootItem.description
                            
                            ActionItem
                            {
                                title: qsTr("Add Shortcut") + Retranslate.onLanguageChanged
                                imageSource: "images/menu/ic_home.png"
                                
                                onTriggered: {
                                    console.log("UserEvent: AddTafsirShortcutFromPickerTriggered");
                                    rootItem.ListItem.view.addToHomeScreen(rootItem.ListItem.data); 
                                }
                            }
                        }
                    ]
                }
            }
        ]
    }
}