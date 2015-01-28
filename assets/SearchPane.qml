import bb.cascades 1.0

NavigationPane
{
    id: navigationPane
    property alias searchText: searchPage.searchText
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    SearchPage
    {
        id: searchPage
        
        onItemTapped: {
            def.source = "AyatPage.qml";
            var page = def.createObject();
            page.arabicId = model.data(indexPath).id;

            navigationPane.push(page);
        }
        
        onTotalResultsFound: {
            navigationPane.parent.unreadContentCount = total;
        }
        
        attachedObjects: [
            HadithLinkHelper
            {
                listView: searchPage.listControl
                
                onLinkingProgress: {
                    searchPage.busyControl.delegateActive = started;
                }
            }
        ]
    }
}