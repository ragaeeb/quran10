import bb.cascades 1.0

StandardListItem
{
    id: sli
    property variant successImageSource
    imageSource: ListItemData.error ? "images/list/transfer_error.png" : successImageSource
    description: Qt.formatDateTime(ListItemData.timestamp)
    status: ListItemData.current ? ListItemData.current+"/"+ListItemData.total : ""
    title: ListItemData.name
    translationX: 150
    
    ListItem.onInitializedChanged: {
        if (initialized) {
            tt.play();
        }
    }
    
    animations: [
        TranslateTransition
        {
            id: tt
            fromX: 150
            toX: 0
            delay: Math.min( 1250, sli.ListItem.indexPath[0]*150 )
            easingCurve: StockCurve.QuadraticOut
        }
    ]
}