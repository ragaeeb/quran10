import bb.cascades 1.2

AyatListItem
{
    id: itemRoot
    actionSetSubtitle: translationLabel.text
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        rightPadding: deviceUtils.du(1)
        leftPadding: deviceUtils.du(1)
        bottomPadding: deviceUtils.du(1)
        
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
        
        gestureHandlers: [
            FontSizePincher
            {
                key: "translationFontSize"
                minValue: 4 ? 4 : 6
                maxValue: 20 ? 20 : 30
                userEventId: "PinchedTranslation"
            }
        ]
    }
}