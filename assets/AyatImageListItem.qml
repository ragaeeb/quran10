import bb.cascades 1.2

AyatListItemBase
{
    id: itemRoot
    
    ListItem.onDataChanged: {
        mushaf.requestAyat(itemRoot, ListItemData.surah_id, ListItemData.verse_id);
    }
    
    function updateState(selected) {
        background = ListItem.selected || ListItem.active || playing ? ListItem.view.activeDefinition.imagePaint : undefined;
    }
    
    ScrollView
    {
        id: scroller
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        scrollViewProperties.scrollMode: ScrollMode.Horizontal
        scrollViewProperties.pinchToZoomEnabled: true
        scrollViewProperties.minContentScale: 1
        property int startX
        property int startY
        
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
            topPadding: tutorial.du(1); bottomPadding: tutorial.du(1); leftPadding: tutorial.du(1); rightPadding: tutorial.du(1)
            
            ImageView
            {
                id: iv
                horizontalAlignment: HorizontalAlignment.Right
                scalingMethod: ScalingMethod.AspectFit
                loadEffect: ImageViewLoadEffect.FadeZoom
                
                onImageChanged: {
                    scroller.scrollToPoint(1440,0);
                }
                
                attachedObjects: [
                    ImageTracker {
                        id: tracker
                        
                        onStateChanged: {
                            if (tracker.state == 2) {
                                iv.image = tracker.image;
                            }
                        }
                    }
                ]
            }
        }
    }
    
    function onDataLoaded(id, data)
    {
        if (ListItemData && data.surah_id == ListItemData.surah_id && data.verse_id == ListItemData.verse_id) {
            tracker.imageSource = data.localUri;
        }
    }
}