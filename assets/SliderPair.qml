import bb.cascades 1.0

Container
{
    property int sliderValue
    property string labelValue
    property alias sliderControl: slider

    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    Label {
        text: labelValue

        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
    }
    
    Slider {
        id: slider
        horizontalAlignment: HorizontalAlignment.Right
        preferredWidth: 225
        
        onValueChanged: {
            sliderValue = value;
        }
    }
}