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
                app.decorateTafsir(adm);
                
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
                    title: ListItemData.author
                    description: ListItemData.title
                    imageSource: ListItemData.imageSource
                    translationY: -150
                    
                    animations: [
                        TranslateTransition
                        {
                            id: tt
                            fromY: -150
                            toY: 0
                            delay: Math.min( 1250, rootItem.ListItem.indexPath[0]*150 )
                            easingCurve: StockCurve.CircularOut
                            duration: 750
                        }
                    ]
                    
                    ListItem.onInitializedChanged: {
                        if (initialized) {
                            tt.play();
                        }
                    }
                    
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
                                    console.log("UserEvent: AddTafsirShortcutFromPicker");
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