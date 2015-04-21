import bb.cascades 1.0

StandardListItem
{
    id: sli
    imageSource: ListItemData.is_companion ? "images/list/ic_companion.png" : "images/list/ic_individual.png"
    description: ListItemData.prefix && ListItemData.prefix.length > 0 ? ListItemData.name : ""
    status: ListItemData.kunya && ListItemData.kunya.length > 0 ? ListItemData.kunya : ""
    title: ListItemData.prefix && ListItemData.prefix.length > 0 ? ListItemData.prefix : ListItemData.name
    opacity: 0
    
    attachedObjects: [
        FadeTransition {
            id: fader
            duration: Math.min( sli.ListItem.indexInSection*300, 750 );
            easingCurve: StockCurve.SineOut
            fromOpacity: 0
            toOpacity: 1
        }
    ]
    
    ListItem.onInitializedChanged: {
        if (initialized) {
            fader.play();
        }
    }
}