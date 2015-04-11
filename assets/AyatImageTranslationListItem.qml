import bb.cascades 1.3

AyatImageListItem
{
    id: itemRoot
    actionSetSubtitle: translationLabel.text
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        rightPadding: ui.sdu(1)
        leftPadding: ui.sdu(1)
        bottomPadding: ui.sdu(1)
        
        Label
        {
            id: translationLabel
            text: ListItemData.translation
            multiline: true
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.color: Color.Black
            textStyle.textAlign: TextAlign.Center
            textStyle.fontSize: FontSize.PointValue
            textStyle.fontSizeValue: itemRoot.ListItem.view.translationSize
            
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
}