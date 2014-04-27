import bb.cascades 1.0

Container {
    id: headerRoot
    property string labelValue
    background: ListItem.view.background.imagePaint
    horizontalAlignment: HorizontalAlignment.Fill
    topPadding: 5
    bottomPadding: 5
    leftPadding: 5
    
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    Label {
        text: labelValue
        horizontalAlignment: HorizontalAlignment.Fill
        textStyle.fontSize: FontSize.XXSmall
        textStyle.color: Color.White
        textStyle.fontWeight: FontWeight.Bold
        textStyle.textAlign: TextAlign.Center
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
    }
}