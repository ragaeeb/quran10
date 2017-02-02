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
            var page = Qt.launch("AyatPage.qml");
            page.surahId = surahId;
            page.verseId = verseId;
        }
        
        onTotalResultsFound: {
            Qt.navigationPane.parent.unreadContentCount = total;
        }
    }
}