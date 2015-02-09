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
        busy.delegateActive = true;
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
            helper.fetchSurahHeader(l, surahId);
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
        
        ProgressControl
        {
            id: busy
            property int loaded: 0
            asset: "images/progress/loading_compare.png"
            
            onDelegateActiveChanged: {
                if (delegateActive) {
                    loaded = 0;
                }
            }
            
            onLoadedChanged: {
                if (loaded == surahIds.length) {
                    delegateActive = false;
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
                        alv.theDataModel.append(data);
                        busy.loaded = busy.loaded+1;
                    } else if (id == QueryId.FetchSurahHeader) {
                        var value = data[0].name;
                        
                        if (helper.showTranslation) {
                            value += qsTr("\n(%1)").arg(data[0].transliteration);
                        }
                        
                        titleLabel.text = value;
                    }
                }
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: surahIds.length/2.0
                }
                
                Container
                {
                    background: back.imagePaint
                    leftPadding: 10; rightPadding: 10; bottomPadding: 10; topPadding: 10
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    Label {
                        id: titleLabel
                        horizontalAlignment: HorizontalAlignment.Fill
                        textStyle.textAlign: TextAlign.Center
                        multiline: true
                    }
                    
                    attachedObjects: [
                        ImagePaintDefinition {
                            id: back
                            imageSource: "images/title/title_bg_compare.png"
                        }
                    ]
                }
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
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
                }
            }
        }
    ]
}