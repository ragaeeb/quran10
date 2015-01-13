import bb.cascades 1.0

Page
{
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: AboutTitleBar
    {
        id: atb
        textColor: Color.White
    }
    
    actions: [
        ActionItem
        {
            imageSource: "images/menu/ic_channel.png"
            title: atb.channelTitle
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: OpenChannelTriggered");
                persist.openChannel();
            }
        },
        
        ActionItem
        {
            imageSource: "images/menu/ic_video_tutorial.png"
            title: qsTr("Video Tutorial") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: VideoTutorialTriggered");
                persist.tutorialVideo("http://youtu.be/7nA27gIxZ08", false);
            }
        }
    ]

    Container
    {
        leftPadding: 10; rightPadding: 10;
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Fill

        ScrollView {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Fill

            Label {
                multiline: true
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.Small
                content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                text: qsTr("\n\nThis app facilitates the reading of Qu'ran for Muslims using BlackBerry 10 to get a smooth and fluid native experience. It includes translations in several languages (Bengali, English, French, Indonesian, Malaysian, Thai, Turkish, Urdu, and many more) as well as the original Arabic version (which is available in both the Uthmani script and the modern simple Imla'ei script). There is also support for verse-by-verse recitation to help you memorize the Qu'ran. You have several reciters to choose from.\n\nThere is built-in support for bookmarking verses to quickly pick up where you left off reading. There is also easy access to copying certain verses to make it easy for you to share it with your contacts.\n\nWhile reading the chapters you can easily view the tafsir (Ibn Katheer's explanation among others) to understand the interpretation of the verse according to the companions of the Prophet (sallahu alayhi wa'sallam).\n\nFinally, there is built-in support to do efficient and fast lookups for any surah or any text in the surah in any of the languages. Note that the search will only be done on the translation that you are currently on.\n\n") + Retranslate.onLanguageChanged;
            }
        }
    }
}