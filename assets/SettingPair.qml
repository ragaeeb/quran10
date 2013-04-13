import bb.cascades 1.0

Container
{
    property alias toggle: animationsToggle
    property string title
    
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    Label {
        text: title
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
    }
    
    ToggleButton {
        id: animationsToggle
    }
}