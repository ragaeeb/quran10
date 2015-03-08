import bb.cascades 1.0

AyatListItem
{
    id: itemRoot
    actionSetSubtitle: translationLabel.text
    
    Label
    {
        id: translationLabel
        text: ListItemData.translation
        multiline: true
        horizontalAlignment: HorizontalAlignment.Fill
        textStyle.color: itemRoot.ListItem.selected || ListItemData.playing ? Color.White : Color.Black
        textStyle.textAlign: TextAlign.Center
        textStyle.fontSize: FontSize.PointValue
        textStyle.fontSizeValue: itemRoot.ListItem.view.translationSize
    }
}