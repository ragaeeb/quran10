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
            
            var d = model.data(indexPath);
            page.surahId = d.surah_id;
            page.verseId = d.verse_id;

            navigationPane.push(page);
        }
        
        onTotalResultsFound: {
            navigationPane.parent.unreadContentCount = total;
        }
    }
}