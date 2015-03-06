import bb.cascades 1.0

Container
{
    id: itemRoot
    property bool peek: ListItem.view.secretPeek
    property bool selection: ListItem.selected
    property bool playing: ListItemData.playing ? ListItemData.playing : false
    property bool active: ListItem.active
    property alias secondLine: labelDelegate
    horizontalAlignment: HorizontalAlignment.Fill
    
    function updateState()
    {
        if (playing) {
            background = Color.create("#ffff8c00")
        } else if (selection) {
            background = Color.DarkGreen
        } else if (active) {
            background = ListItem.view.activeDefinition.imagePaint
        } else {
            background = undefined
        }
    }
    
    onCreationCompleted: {
        selectionChanged.connect(updateState);
        playingChanged.connect(updateState);
        activeChanged.connect(updateState);
        updateState();
    }
    
    ListItem.onDataChanged: {
        scroller.scrollToPoint(1440, 0);
        scroller.zoomToPoint(1440, 0, 2);
    }
    
    onPeekChanged: {
        if (peek) {
            showAnim.play();
        }
    }
    
    opacity: 0
    animations: [
        FadeTransition
        {
            id: showAnim
            fromOpacity: 0
            toOpacity: 1
            duration: Math.max( 200, Math.min( itemRoot.ListItem.indexPath[0]*300, 750 ) );
            easingCurve: StockCurve.QuadraticIn
        }
    ]
    
    ListItem.onInitializedChanged: {
        if (initialized) {
            showAnim.play();
        }
    }
    
    ListItem.onViewChanged: {
        if (view) {
            headerRoot.background = itemRoot.ListItem.view.background.imagePaint;
        }
    }
    
    Container
    {
        id: headerRoot
        horizontalAlignment: HorizontalAlignment.Fill
        topPadding: 5
        bottomPadding: 5
        leftPadding: 5
        
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        
        Label {
            text: "%1:%2".arg(ListItemData.surah_id).arg(ListItemData.verse_id)
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.fontSize: FontSize.XXSmall
            textStyle.color: Color.White
            textStyle.fontWeight: FontWeight.Bold
            textStyle.textAlign: TextAlign.Center
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
        }
    }
    
    Container
    {
        topPadding: 5; bottomPadding: 5; leftPadding: 5; rightPadding: 5
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        ScrollView
        {
            id: scroller
            horizontalAlignment: HorizontalAlignment.Fill
            scrollViewProperties.scrollMode: ScrollMode.Horizontal
            scrollViewProperties.pinchToZoomEnabled: true
            scrollViewProperties.minContentScale: 1
            property int startX
            property int startY
            visible: ListItemData.imagePath ? true : false
            
            onTouch: {
                if ( event.isDown() )
                {
                    startX = event.localX;
                    startY = event.localY;
                    itemRoot.ListItem.view.blockPeek = true;
                } else if ( event.isUp() || event.isCancel() ) {
                    if ( Math.abs(event.localX-startX) > 10 || Math.abs(event.localY-startY) > 10 ) {
                        itemRoot.ListItem.view.scrolled = true;
                    }
                    
                    itemRoot.ListItem.view.blockPeek = false;
                }
            }
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                ImageView
                {
                    id: iv
                    horizontalAlignment: HorizontalAlignment.Right
                    scalingMethod: ScalingMethod.AspectFit
                    loadEffect: ImageViewLoadEffect.FadeZoom
                    imageSource: "file://"+ListItemData.imagePath
                }
            }
        }
        
        ControlDelegate
        {
            id: labelDelegate
            delegateActive: ListItemData.translation ? true : false
            horizontalAlignment: HorizontalAlignment.Fill
            sourceComponent: ComponentDefinition
            {
                id: labelDefinition
                
                Label {
                    id: translationLabel
                    text: ListItemData.translation
                    multiline: true
                    horizontalAlignment: HorizontalAlignment.Fill
                    textStyle.color: selection || playing ? Color.White : Color.Black
                    textStyle.textAlign: TextAlign.Center
                    visible: text.length > 0;
                    textStyle.fontSize: {
                        var translationSize = itemRoot.ListItem.view.translationSize;
                        
                        if (translationSize == 1) {
                            return FontSize.Small;
                        } else if (translationSize == 2) {
                            return FontSize.Medium;
                        } else {
                            return FontSize.XXLarge;
                        }
                    }
                }
            }
        }
    }
}