import bb.cascades 1.0

AyatListItemBase
{
    id: itemRoot
    
    ListItem.onDataChanged: {
        scroller.scrollToPoint(1440,0);
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
            topPadding: 5; bottomPadding: 5; leftPadding: 5; rightPadding: 5
            
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
}