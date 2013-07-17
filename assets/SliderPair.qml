import bb.cascades 1.0

Container
{
    property string key
    property int sliderValue
    property string labelValue
    property int from
    property int to

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
        value: persist.getValueFor(key);
        horizontalAlignment: HorizontalAlignment.Right
        preferredWidth: 225
        fromValue: from
        toValue: to
        
        onValueChanged: {
            sliderValue = value;
        }
    }
    
    onSliderValueChanged: {
        persist.saveValueFor(key, sliderValue);
    }
}