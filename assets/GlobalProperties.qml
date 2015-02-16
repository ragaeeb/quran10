import bb.cascades 1.2

QtObject
{
    property alias textFont: customFontDef.style
    signal lastPositionUpdated();

    property variant customFont: TextStyleDefinition
    {
        id: customFontDef
        fontFamily: "uthman_bold"
        
        rules: [
            FontFaceRule {
                source: "fonts/me_quran.ttf"
                fontFamily: "Regular"
            }
        ]
    }
}