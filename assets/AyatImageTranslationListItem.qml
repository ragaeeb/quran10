import bb.cascades 1.2

AyatImageListItem
{
    id: itemRoot
    actionSetSubtitle: translationLabel.text
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        rightPadding: tutorial.du(1)
        leftPadding: tutorial.du(1)
        bottomPadding: tutorial.du(1)
        
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