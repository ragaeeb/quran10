import bb.cascades 1.2

ControlDelegate
{
    horizontalAlignment: HorizontalAlignment.Fill
    property real sizeValue
    
    sourceComponent: ComponentDefinition
    {
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill

            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            Label {
                text: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
                textStyle.color: Color.Black
                textStyle.fontSize: FontSize.PointValue
                textStyle.fontSizeValue: sizeValue
                textStyle.base: global.textFont
                
                multiline: true
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
            }
        }
    }
}