import bb.cascades 1.0

Sheet
{
    id: root
    
    Page
    {
        titleBar: TitleBar
        {
            title: qsTr("Shadda Tutorial") + Retranslate.onLanguageChanged
            
            dismissAction: ActionItem
            {
                enabled: checkBox.checked
                title: qsTr("Back") + Retranslate.onLanguageChanged
                imageSource: "images/title/ic_prev.png"
                
                onTriggered: {
                    console.log("UserEvent: ShaddaBack");
                    persist.saveValueFor("shaddaTutorial", 1);
                    root.close();
                }
            }
        }
        
        ScrollView
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                topPadding: 10; bottomPadding: 10; rightPadding: 10; leftPadding: 10
                
                ImageView
                {
                    imageSource: "images/toast/tutorial_shadda.png"
                    horizontalAlignment: HorizontalAlignment.Center
                    
                    animations: [
                        RotateTransition {
                            id: tt
                            fromAngleZ: 360
                            toAngleZ: 0
                            duration: 1200
                            easingCurve: StockCurve.ElasticInOut
                        }
                    ]
                }
                
                Label
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    textStyle.textAlign: TextAlign.Center
                    content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                    multiline: true
                    text: qsTr("\n\nالسلام عليكم\n\nSome users have left reviews that there are mistakes in the text. Please note that the above two in Arabic are identical!\n\nIf the vowel is on top of the shadda (w) it takes the ruling of a fatha. If the vowel is underneath the shadda, it would sound exactly like if the vowel was underneath the letter itself. Both ways are a valid, and thus this is just a matter of choice.\n\nIf you are not used to reading this way, please familiarize yourself with this rule in Arabic, or use the Mushaf feature to read the Qu'ran instead which uses the other style. JazakAllahu khair.\n\nIf you would like to read up on the Shadda rules please see here:\nhttps://en.wikipedia.org/wiki/Shadda") + Retranslate.onLanguageChanged
                    opacity: 0
                    bottomMargin: 40
                    
                    animations: [
                        FadeTransition {
                            id: fader
                            fromOpacity: 0
                            toOpacity: 1
                            easingCurve: StockCurve.CubicOut
                            duration: 1000
                        }
                    ]
                }
                
                CheckBox {
                    id: checkBox
                    topMargin: 40
                    text: qsTr("I Understand") + Retranslate.onLanguageChanged
                }
            }
        }
    }
    
    onOpened: {
        fader.play();
        tt.play();
    }
    
    onClosed: {
        destroy();
    }
}