import bb.cascades 1.3

AyatListItemBase
{
    id: itemRoot
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        rightPadding: ui.sdu(1)
        leftPadding: ui.sdu(1)
        
        Label
        {
            id: firstLabel
            text: ListItemData.arabic
            multiline: true
            horizontalAlignment: HorizontalAlignment.Fill
            
            textStyle {
                color: itemRoot.ListItem.selected || ListItemData.playing ? Color.White : Color.Black
                base: global.textFont
                textAlign: TextAlign.Right;
                fontSizeValue: itemRoot.ListItem.view.primarySize
                fontSize: FontSize.PointValue
            }
        }
    }
}