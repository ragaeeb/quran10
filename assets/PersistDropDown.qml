import bb.cascades 1.0

DropDown
{
    property string key
    horizontalAlignment: HorizontalAlignment.Fill
    
    onCreationCompleted: {
        var primary = persist.getValueFor(key)
        
        for (var i = 0; i < options.length; i ++) {
            if (options[i].value == primary) {
                options[i].selected = true
                break;
            }
        }
    }
    
    onSelectedValueChanged: {
        persist.saveValueFor(key, selectedValue);
    }    
}