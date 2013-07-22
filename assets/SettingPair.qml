import bb.cascades 1.0

Container
{
    property string key
    property alias toggle: animationsToggle
    property string title
    
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    Label {
        text: title
        verticalAlignment: VerticalAlignment.Center
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
    }
    
    ToggleButton {
        id: animationsToggle
        checked: persist.getValueFor(key) == 1
        
        onCheckedChanged: {
            persist.saveValueFor(key, checked ? 1 : 0);
        }
    }
}