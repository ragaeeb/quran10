import bb.cascades 1.0

NavigationPane
{
    id: navigationPane
    property alias searchText: searchPage.searchText
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    SearchPage
    {
        id: searchPage
        
        onPicked: {
            def.source = "AyatPage.qml";
            var page = def.createObject();
            
            page.surahId = surahId;
            page.verseId = verseId;

            navigationPane.push(page);
        }
        
        onTotalResultsFound: {
            navigationPane.parent.unreadContentCount = total;
        }
    }
}