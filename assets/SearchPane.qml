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
        
        onPicked: {
            var page = global.createObject("AyatPage.qml");
            
            page.surahId = surahId;
            page.verseId = verseId;

            navigationPane.push(page);
        }
        
        onTotalResultsFound: {
            navigationPane.parent.unreadContentCount = total;
        }
    }
}