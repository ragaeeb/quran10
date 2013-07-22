import bb.cascades 1.0

Sheet
{
    id: root
    
    onClosed: {
        destroy();
    }
    
    Page
    {
        titleBar: TitleBar {
            title: qsTr("Agreement") + Retranslate.onLanguageChanged

            acceptAction: ActionItem {
                title: qsTr("Accept") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    if (hideNextTime.checked) {
                        persist.saveValueFor("hideAgreement", 1);
                    }
                    
                    root.close();
                }
            }
        }
        
        Container
        {
            leftPadding: 10;rightPadding: 10;topPadding: 10; bottomPadding: 10
            
            ScrollView
            {
                scrollViewProperties.pinchToZoomEnabled: true
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                Label {
                    multiline: true
                    textStyle.textAlign: TextAlign.Center
                    verticalAlignment: VerticalAlignment.Center
                    content.flags: TextContentFlag.ActiveText
                    text: qsTr("As'salamu'alaikum wa rahmatullahi wabarakathu,\n\nMay Allah reward you for supporting Quran10 and may it be beneficial for you.\n\nSome users have reported that the arabic text has errors. However after investigation we determined that there was not an issue in the text and instead it was due to the user not being familiar with the Arabic scripts used.\n\nThere exists both the Uthmani script (which is the classical Arabic font which many users may not be used to), and the modern Arabic script (which is the more popular font). Due to the user not being familiar with the script they were reporting errors when in reality there was not.\n\nTo facilitate this for the users, we now have the option for you to select both the Modern Arabic script as well as the Uthmani script so you can read in whichever font you are more comfortable.\n\nAlso please note the rulings on the Shadda (small 'w'): If a vowel (fatha, kasra, dhama) is underneath the Shaddah then it takes the same rulling as if the vowel is underneath the letter itself. Please refer to the wiki article on Wikipedia regarding the Shadda:\nhttps://en.wikipedia.org/wiki/Shadda\nIf this is difficult for you, we have included an additional feature called the 'Mushaf' which you can also use.\n\nWe use the Tanzil database (which has been verified by several sources on accuracy). If you however still find there are errors in the text, please report the exact Surah and Ayat #, what the expected text is and what the actual text showing is and we will be sure to have one of our developers look at it. JazakAllahu khair.\n\nCanada Inc. Support") + Retranslate.onLanguageChanged
                }   
            }

            CheckBox {
                id: hideNextTime
                text: qsTr("Don't show again")
                verticalAlignment: VerticalAlignment.Bottom
            }
        }
    }
}
