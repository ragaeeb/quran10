import bb.cascades 1.0
import com.canadainc.data 1.0

Container
{
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    
    Header {
        title: qsTr("Explanations") + Retranslate.onLanguageChanged
    }
    
    ListView
    {
        id: tafsirList
        maxHeight: 125
        
        layout: StackListLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        
        dataModel: ArrayDataModel {
            id: adm
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
        
        listItemComponents: [
            ListItemComponent
            {
                Container
                {
                    id: rootItem
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    property real startAngle: ListItem.indexInSection & 1 ? 360 : 0
                    property real endAngle: ListItem.indexInSection & 1 ? 0 : 360
                    topPadding: 10; leftPadding: 10; rightPadding: 10; bottomPadding: 10
                    rotationZ: startAngle
                    
                    animations: [
                        RotateTransition {
                            id: rotator
                            fromAngleZ: rootItem.startAngle
                            toAngleZ: rootItem.endAngle
                            delay: 500
                            duration: 1000
                            easingCurve: StockCurve.ExponentialOut
                        }
                    ]
                    
                    ListItem.onInitializedChanged: {
                        if (initialized) {
                            rotator.play();
                        }
                    }
                    
                    contextActions: [
                        ActionSet
                        {
                            title: rootItem.ListItem.data.author
                            subtitle: rootItem.ListItem.data.title
                            
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
                    
                    ImageView
                    {
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        imageSource: "images/list/ic_tafsir.png"
                    }
                }
            }
        ]
        
        function onDataLoaded(id, data)
        {
            if (id == QueryId.FetchTafsirForAyat)
            {
                adm.append(data);
                
                if (data.length == 1) {
                    showExplanation(data[0].id);
                }
            }
        }
        
        onCreationCompleted: {
            helper.fetchAllTafsirForAyat(tafsirList, root.surahId, root.verseId);
        }
    }
}