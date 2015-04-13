import bb.cascades 1.0

Container
{
    id: rootItem
    property alias bodyText: bodyLabel
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    background: ListItem.active || ListItem.selected ? global.headerBackground.imagePaint : undefined
    
    ListItem.onInitializedChanged: {
        if (initialized) {
            showAnim.play();
        }
    }
    
    Header {
        id: header
        title: ListItemData.name
        subtitle: "%1:%2".arg(ListItemData.surah_id).arg(ListItemData.verse_id)
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        leftPadding: 10; rightPadding: 10; bottomPadding: 10
        
        Label {
            id: bodyLabel
            content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
            multiline: true
            textStyle.color: rootItem.ListItem.active || rootItem.ListItem.selected ? Color.Black : undefined
            textStyle.fontSize: FontSize.PointValue
        }
    }
    
    opacity: 0
    animations: [
        FadeTransition
        {
            id: showAnim
            fromOpacity: 0
            toOpacity: 1
            easingCurve: StockCurve.QuinticOut
            duration: Math.max( 200, Math.min( rootItem.ListItem.indexPath[0]*300, 750 ) );
        }
    ]
}