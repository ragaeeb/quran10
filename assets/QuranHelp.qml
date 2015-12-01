import bb.cascades 1.2

HelpPage
{
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    videoTutorialUri: "http://youtu.be/YOXtjnNWVZM"

    onClearCacheTriggered: {
        offloader.clearCachedDB();
    }

    actions: [
        ActionItem
        {
            id: updateCheck
            imageSource: "images/menu/ic_update_check.png"
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
                id: disabledUpdates
                imageSource: "images/dropdown/ic_db_disabled.png"
                description: qsTr("Never check for tafsir updates") + Retranslate.onLanguageChanged
                text: qsTr("Disabled") + Retranslate.onLanguageChanged
                value: -1
            }
            
            Option {
                id: promptUpdates
                description: qsTr("Ask before downloading update") + Retranslate.onLanguageChanged
                imageSource: "images/dropdown/ic_db_prompt.png"
                text: qsTr("Prompt") + Retranslate.onLanguageChanged
                value: undefined
            }
            
            Option {
                id: autoUpdates
                description: qsTr("Automatically download updates when they are available") + Retranslate.onLanguageChanged
                imageSource: "images/dropdown/ic_db_auto.png"
                text: qsTr("Automatic") + Retranslate.onLanguageChanged
                value: 1
            }
            
            onExpandedChanged: {
                if (expanded)
                {
                    tutorial.execBelowTitleBar( "disabledUpdates", qsTr("As more and more tafsir and biographies become available, the app can try to download them. Use the '%1' option to never check for these updates.").arg(disabledUpdates.text), tutorial.du(16) );
                    tutorial.execBelowTitleBar( "promptUpdates", qsTr("To be prompted before downloading the latest tafsir updates, use the '%1' option.").arg(promptUpdates.text), tutorial.du(24) );
                    tutorial.execBelowTitleBar( "autoUpdates", qsTr("To automatically download the latest tafsir updates as they become available, use the '%1' option.").arg(autoUpdates.text), tutorial.du(32) );
                }
            }
        }
    }
    
    onCreationCompleted: {
        tutorial.execActionBar("forceUpdate", qsTr("Press-and-hold here and choose '%1' to check for the latest tafsir, quotes, and biographies.").arg(updateCheck.title), "l");
    }
}