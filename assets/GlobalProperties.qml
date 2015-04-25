import bb.cascades 1.2

QtObject
{
    property alias textFont: customFontDef.style
    signal lastPositionUpdated();
    signal bookmarksUpdated();

    property variant customFont: TextStyleDefinition
    {
        id: customFontDef
        fontFamily: "Regular"
        
        rules: [
            FontFaceRule {
                source: "fonts/me_quran.ttf"
                fontFamily: "Regular"
            }
        ]
    }
    
    property variant headerBackground: ImagePaintDefinition {
        imageSource: "images/backgrounds/header_bg.png"
    }
    
    property variant mainBackground: ImagePaintDefinition {
        imageSource: "images/backgrounds/background.png"
    }
    
    property variant definition: ComponentDefinition {}
    
    function createObject(qml)
    {
        definition.source = qml;
        return definition.createObject();
    }
    
    function getHeaderData(ListItem) {
        return ListItem.view.dataModel.data( [ListItem.indexPath[0],0] );
    }
    
    function getHijriYear(y1, y2)
    {
        if (y1 > 0 && y2 > 0) {
            return qsTr("%1-%2 AH").arg(y1).arg(y2);
        } else if (y1 < 0 && y2 < 0) {
            return qsTr("%1-%2 BH").arg( Math.abs(y1) ).arg( Math.abs(y2) );
        } else if (y1 < 0 && y2 > 0) {
            return qsTr("%1 BH - %2 AH").arg( Math.abs(y1) ).arg(y2);
        } else {
            return y1 > 0 ? qsTr("%1 AH").arg(y1) : qsTr("%1 BH").arg( Math.abs(y1) );
        }
    }
    
    function getCapitalizedClipboard()
    {
        var x = persist.getClipboardText();
        x = x.charAt(0).toUpperCase() + x.slice(1); 
        return x;
    }
    
    function getSuffix(birth, death, isCompanion, female)
    {
        if (isCompanion)
        {
            if (female) {
                return qsTr("رضي الله عنها");
            } else {
                return qsTr("رضي الله عنه");
            }
        } else if (death) {
            return qsTr(" (رحمه الله)");
        } else if (birth) {
            return qsTr(" (حفظه الله)");
        }
        
        return "";
    }
}