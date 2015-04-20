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
    
    function getSuffix(birth, death, companionId, female)
    {
        if (companionId)
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