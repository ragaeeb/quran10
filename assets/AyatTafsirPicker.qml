import bb.cascades 1.0

Container
{
    Header {
        title: qsTr("Explanations") + Retranslate.onLanguageChanged
    }
    
    ListView
    {
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
                ImageView
                {
                    id: rootItem
                    property real startAngle: ListItem.indexInSection & 1 ? 360 : 0
                    property real endAngle: ListItem.indexInSection & 1 ? 0 : 360
                    horizontalAlignment: HorizontalAlignment.Center
                    imageSource: "images/list/ic_tafsir.png"
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
                                imageSource: "images/menu/ic_home_add.png"
                                
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
        
        onCreationCompleted: {
            adm.append(explanations);
        }
    }
}