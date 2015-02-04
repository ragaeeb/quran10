import bb.cascades 1.2

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        titleBar: TitleBar {
            title: qsTr("Transfers") + Retranslate.onLanguageChanged
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            ListView
            {
                id: listView
                dataModel: queue
                
                listItemComponents: [
                    ListItemComponent
                    {
                        StandardListItem
                        {
                            imageSource: "images/list/ic_supplication.png"
                            title: ListItemData.name
                        }
                    }
                ]
            }
        }
    }
}