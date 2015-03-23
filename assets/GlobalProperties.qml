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