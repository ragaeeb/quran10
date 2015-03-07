import bb.cascades 1.0

AyatListItemBase
{
    id: itemRoot
    
    TextArea
    {
        id: firstLabel
        text: ListItemData.arabic
        editable: false
        backgroundVisible: false
        horizontalAlignment: HorizontalAlignment.Fill
        
        textStyle {
            color: ListItem.selected || ListItemData.playing ? Color.White : Color.Black
            base: global.textFont
            textAlign: TextAlign.Right;
            fontSizeValue: itemRoot.ListItem.view.primarySize
            fontSize: FontSize.PointValue
        }
    }
}