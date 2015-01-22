import bb.cascades 1.2

ControlDelegate
{
    horizontalAlignment: HorizontalAlignment.Fill
    
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
                textStyle.fontSizeValue: primarySize
                multiline: true
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
            }
        }
    }
}