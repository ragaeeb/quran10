import bb.cascades 1.0

Container
{
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
        fromValue: 900
        toValue: 3000
        value: persist.getValueFor("delay")
        
        onValueChanged: {
            persist.saveValueFor("delay", value)
            infoText.text = qsTr("Gestures will be interpreted after %1 seconds. Note that if this is too short, and you have some complex gestures, it might make it harder for the system to always interpret them. If your gestures are not always recognized properly, increase this value.").arg(value/1000)
        }
    }
    
    layoutProperties: StackLayoutProperties {
        spaceQuota: 1
    }
}