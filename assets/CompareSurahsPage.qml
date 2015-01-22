import bb.cascades 1.2
import com.canadainc.data 1.0

Page
{
    id: previewPage
    property variant surahIds
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: TitleBar {
        title: qsTr("Compare")
    }
    
    onPeekedAtChanged: {
        for (var i = listContainer.count()-1; i >= 0; i--) {
            listContainer.at(i).list.secretPeek = peekedAt; 
        }
    }
    
    onSurahIdsChanged: {
        loadVerses();
    }
    
    function loadVerses()
    {
        busy.loaded = 0;
        listContainer.removeAll();
        
        for (var i = surahIds.length-1; i >= 0; i--)
        {
            var surahId = surahIds[i];
            
            var l = listDelegate.createObject();
            l.list.chapterNumber = surahId;
            
            if (i == 0) {
                l.showSeparator = false;
            }
            
            listContainer.add(l);
            helper.fetchAllAyats(l, surahId);
        }
    }
    
    function reloadNeeded(key)
    {
        if (key == "primarySize" || key == "translationSize") {
            loadVerses();
        }
    }
    
    onCreationCompleted: {
        persist.settingChanged.connect(reloadNeeded);
    }
    
    Container
    {
        layout: DockLayout {}
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        background: Color.White
        
        Container
        {
            id: listContainer
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
        }
        
        ActivityIndicator
        {
            id: busy
            property int loaded: 0
            running: true
            visible: running
            preferredHeight: 250
            horizontalAlignment: HorizontalAlignment.Center
            
            onLoadedChanged: {
                if (loaded == surahIds.length) {
                    running = false;
                }
            }
        }
    }
    
    attachedObjects: [
        ComponentDefinition
        {
            id: listDelegate

            Container
            {
                id: singleSurah
                property alias showSeparator: separator.visible
                property alias list: alv
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllAyats)
                    {
                        alv.theDataModel.clear();
                        alv.theDataModel.insertList(data);
                        busy.loaded = busy.loaded+1;
                    }
                }
                
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    AyatListView {
                        id: alv
                    }
                    
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                }
                
                ImageView {
                    id: separator
                    imageSource: "images/vertical_separator.png"
                    verticalAlignment: VerticalAlignment.Fill
                    leftMargin: 0; rightMargin: 0
                }
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: surahIds.length/2.0
                }
            }
        }
    ]
}