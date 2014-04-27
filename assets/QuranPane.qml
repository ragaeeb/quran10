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
                imageSource: "images/menu/ic_mushaf.png"
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
    
    onCreationCompleted: {
        if ( persist.tutorial( "tutorialAlphanumeric", qsTr("Did you know you can quickly jump to a specific verse by typing its chapter number followed by a ':' and followed by the verse number.\n\nFor example, to jump to Surah Al-Baqara Verse #2, type '2:2' into the search field!"), "asset:///images/ic_quran.png" ) ) {}
    }
}