import bb.cascades 1.0

Page
{
    id: root
    property alias suitePageId: parser.suitePageId
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onCreationCompleted: {
        content = parser.mainContent;
    }
    
    onSuitePageIdChanged: {
        parser.scalerAnim.play();
    }
    
    attachedObjects: [
        AyatTafsirParser {
            id: parser
            
            onNotFound: {
                var params = {'language': helper.translation, 'tafsir': helper.tafsirName, 'translation': helper.translationName};
                helper.updateCheckNeeded(params);
            }
        }
    ]
    
    actions: [
        InvokeActionItem
        {
            id: shareAction
            imageSource: "images/menu/ic_share.png"
            title: qsTr("Share") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            
            onTriggered: {
                console.log("UserEvent: ShareArticle");
                data = persist.convertToUtf8( "quran://tafsir/"+suitePageId.toString() );
                reporter.record( "ShareArticle", suitePageId.toString() );
            }
        }
    ]
}