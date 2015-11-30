import bb.cascades 1.3

HelpPage
{
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll

    actions: [
        ActionItem
        {
            id: updateCheck
            imageSource: "images/menu/ic_help.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            title: qsTr("Check for Updates") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: CheckForUpdate");
                enabled = false;
                var params = {'language': helper.translation, 'tafsir': helper.tafsirName, 'translation': helper.translationName};
                helper.updateCheckNeeded(params);
                
                reporter.record("CheckForTafsirUpdate", helper.translation);
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
    ]
    
    function cleanUp()
    {
        queue.requestComplete.disconnect(updateCheck.onFinished);
        helper.textualChange.disconnect(versionInfo.recompute);
    }

    Container
    {
        leftPadding: 10; rightPadding: 10; topPadding: 10
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Fill
        
        Label
        {
            id: versionInfo
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.textAlign: TextAlign.Center
            
            function recompute()
            {
                var tafsirVersion = parseInt(helper.tafsirVersion);
                var translationVersion = parseInt(helper.translationVersion);
                
                if (tafsirVersion > 0 && translationVersion > 0) {
                    text = qsTr("Tafsir Last Updated: %1\nTranslation Last Updated: %2").arg( Qt.formatDate(tafsirVersion, "MMM d, yyyy") ).arg( Qt.formatDate(translationVersion, "MMM d, yyyy") );
                } else if (tafsirVersion > 0) {
                    text = qsTr("Tafsir Last Updated: %1").arg( new Date(tafsirVersion).toDateString() );
                } else if (translationVersion > 0) {
                    text = qsTr("Translation Last Updated: %1").arg( new Date(translationVersion).toDateString() );
                } else {
                    text = qsTr("Database version information not detected...");
                }
            }
            
            onCreationCompleted: {
                helper.textualChange.connect(recompute);
                recompute();
            }
        }
        
        PersistDropDown
        {
            isFlag: true
            key: "updateCheckFlag"
            title: qsTr("Automatic Database Updating") + Retranslate.onLanguageChanged
            topMargin: 20
            
            Option {
                imageSource: "images/toast/yellow_delete.png"
                text: qsTr("Disabled") + Retranslate.onLanguageChanged
                value: -1
            }
            
            Option {
                imageSource: "images/menu/ic_help.png"
                text: qsTr("Prompt") + Retranslate.onLanguageChanged
                value: undefined
            }
            
            Option {
                imageSource: "images/menu/ic_select_all.png"
                text: qsTr("Automatic") + Retranslate.onLanguageChanged
                value: 1
            }
        }
    }
    
    onCreationCompleted: {
        tutorial.execActionBar("forceUpdate", qsTr("Press-and-hold here and choose '%1' to check for the latest tafir, quotes, and biographies.").arg(updateCheck.title), "l");
    }
}