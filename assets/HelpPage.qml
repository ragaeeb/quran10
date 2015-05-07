import bb.cascades 1.0

Page
{
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll

    titleBar: AboutTitleBar
    {
        id: atb
        videoTutorialUri: "http://youtu.be/7nA27gIxZ08"

        expandedContent: [
            Label
            {
                id: versionInfo
                horizontalAlignment: HorizontalAlignment.Fill
                
                onCreationCompleted: {
                    var body = qsTr("Version information not detected...");
                    var tafsirVersion = parseInt(helper.tafsirVersion);
                    var translationVersion = parseInt(helper.translationVersion);
                    
                    if (tafsirVersion > 0 && translationVersion > 0) {
                        text = qsTr("Tafsir Last Updated: %1\nTranslation Last Updated: %2").arg( Qt.formatDate(tafsirVersion, "MMM d, yyyy") ).arg( Qt.formatDate(translationVersion, "MMM d, yyyy") );
                    } else if (tafsirVersion > 0) {
                        text = qsTr("Tafsir Last Updated: %1").arg( new Date(tafsirVersion).toDateString() );
                    } else if (translationVersion > 0) {
                        text = qsTr("Translation Last Updated: %1").arg( new Date(translationVersion).toDateString() );
                    }
                }
                
                contextActions: [
                    ActionSet
                    {
                        id: actionSet
                        title: versionInfo.text
                        
                        ActionItem
                        {
                            imageSource: "images/menu/ic_upload_local.png"
                            title: qsTr("Check for Updates") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: CheckForUpdate");
                                enabled = false;
                                var params = {'language': helper.translation};
                                helper.updateCheckNeeded(params);
                                
                                analytics.record("CheckForTafsirUpdate", helper.translation);
                            }
                            
                            function onFinished(cookie, data)
                            {
                                if (cookie.updateCheck) {
                                    enabled = true;
                                }
                            }
                            
                            onCreationCompleted: {
                                queue.requestComplete.connect(onFinished);
                            }
                        }
                    }
                ]
            }
        ]
    }

    Container
    {
        leftPadding: 10; rightPadding: 10;
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Fill

        ScrollView
        {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Fill

            Label {
                multiline: true
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.Small
                content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                text: qsTr("\n\nThis app facilitates the reading of Qu'ran for Muslims using BlackBerry 10 to get a smooth and fluid native experience. It includes translations in several languages (English, French, Indonesian, Thai, Urdu, and others) as well as the original Arabic version. There is support for transliteration as well as verse-by-verse recitation to help you memorize the Qu'ran. You have several reciters to choose from.\n\nThere is built-in support for bookmarking verses to quickly pick up where you left off reading. There is also easy access to copying certain verses to make it easy for you to share it with your contacts.\n\nWhile reading the chapters you can easily view the tafsir (Ibn Katheer's explanation among others) to understand the interpretation of the verse according to the companions of the Prophet (sallahu alayhi wa'sallam).\n\nFinally, there is built-in support to do efficient and fast lookups for any surah or any text in the surah in any of the languages. Note that the search will only be done on the translation that you are currently on.\n\n") + Retranslate.onLanguageChanged;
            }
        }
    }
}