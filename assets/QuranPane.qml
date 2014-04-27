import bb.cascades 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    SurahPickerPage
    {
        actions: [
            ActionItem {
                title: qsTr("Mushaf") + Retranslate.onLanguageChanged
                imageSource: "images/ic_mushaf.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    definition.source = "MushafSheet.qml";
                    var sheet = definition.createObject();
                    
                    sheet.open();
                }
                
                shortcuts: [
                    Shortcut {
                        key: qsTr("M") + Retranslate.onLanguageChanged
                    }
                ]
            }
        ]
        
        onPicked: {
            definition.source = "SurahPage.qml";
            var surahPage = definition.createObject();
            navigationPane.push(surahPage);
            
            surahPage.surahId = chapter;            
            surahPage.requestedVerse = verse;
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}