import bb.cascades 1.0

StandardListItem
{
    id: sli
    property variant successImageSource
    imageSource: ListItemData.error ? "images/list/transfer_error.png" : successImageSource
    //description: Qt.formatDateTime(ListItemData.timestamp)
    status: ListItemData.current ? ListItemData.current+"/"+ListItemData.total : ""
    title: ListItemData.name
}