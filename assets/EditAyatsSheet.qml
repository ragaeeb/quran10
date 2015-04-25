import bb.cascades 1.2

Sheet
{
    id: sheet
    
    onClosed: {
        destroy();
    }
    
    onOpened: {
        bodyField.requestFocus();
    }
    
    Page
    {
        titleBar: TitleBar
        {
            title: qsTr("Edit Ayats") + Retranslate.onLanguageChanged
            
            dismissAction: ActionItem
            {
                title: qsTr("Dismiss") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: DismissEditAyat");
                    sheet.close();
                }
            }
            
            acceptAction: ActionItem
            {
                title: qsTr("Analyze") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: AnalayzeAyatData");
                    admin.analyzeKingFahad(bodyField.text);
                }
            }
        }
        
        TextArea
        {
            id: bodyField
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            backgroundVisible: false
            content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
            hintText: qsTr("Enter ayat here...") + Retranslate.onLanguageChanged
            input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
            topPadding: 0; topMargin: 0
        }
    }
}