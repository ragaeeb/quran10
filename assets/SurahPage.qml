import bb.cascades 1.2
import com.canadainc.data 1.0

Page
{
    id: surahPage
    property int fromSurahId
    property int toSurahId
    property int toVerseId
    property int surahId
    property int verseId
    property alias showContextMenu: awaker.showContext
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal picked(int surahId, int verseId)
    signal openChapterTafsir(int surahId)
    
    function cleanUp()
    {
        awaker.cleanUp();
        ctb.cleanUp();
        helper.textualChange.disconnect(reloadNeeded);
    }
    
    onSurahIdChanged: {
        fromSurahId = surahId;
        toSurahId = surahId;
        
        loadAyats();
    }
    
    function loadAyats()
    {
        if (fromSurahId > 0 && toSurahId > 0)
        {
            ctb.chapterNumber = awaker.lv.chapterNumber = fromSurahId;
            busy.delegateActive = true;
            helper.fetchAllAyats(surahPage, fromSurahId, toSurahId, toVerseId);
        }
    }
    
    function reloadNeeded() {
        surahIdChanged();
    }
    
    onPeekedAtChanged: {
        awaker.lv.secretPeek = peekedAt;
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchAllAyats)
        {
            if ( awaker.lv.theDataModel.isEmpty() || awaker.lv.theDataModel.size() != data.length )
            {
                awaker.lv.theDataModel.clear();
                awaker.lv.theDataModel.append(data);

                if (verseId > 0) {
                    var target = [verseId-1];
                    awaker.lv.scrollToItem(target, ScrollAnimation.None);
                    awaker.lv.select(target, true);
                } else if (fromSurahId > 1 && fromSurahId != 9) {
                    awaker.lv.scrollToPosition(0, ScrollAnimation.None);
                    awaker.lv.scroll(-195, ScrollAnimation.Smooth);
                }
            } else {
                for (var i = data.length-1; i >= 0; i--) {
                    awaker.lv.theDataModel.replace(i, data[i]);
                }
            }
            
            busy.delegateActive = false;
        }
    }

    onCreationCompleted: {
        helper.textualChange.connect(reloadNeeded);
        mainContainer.add(awaker.lv);
    }

    titleBar: ChapterTitleBar
    {
        id: ctb
        
        onNavigationTapped: {
            if (right) {
                ++surahId;
            } else {
                --surahId;
            }
            
            verseId = 0;
            
            awaker.lazyPlayer.stop();
        }
        
        onTitleTapped: {
            openChapterTafsir(chapterNumber);
        }
    }

    Container
    {
        layout: DockLayout {}
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        background: Color.White
        
        Container
        {
            id: mainContainer
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_surah.png"
        }
    }
    
    attachedObjects: [
        Awaker
        {
            id: awaker
            parentPage: surahPage
            
            onVersePicked: {
                picked(surahId, verseId);
            }
        }
    ]
}