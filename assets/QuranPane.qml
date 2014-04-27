import bb.cascades 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();

        if (top == pickerPage)
        {
            if ( persist.tutorial( "tutorialAlphanumeric", qsTr("Did you know you can quickly jump to a specific verse by typing its chapter number followed by a ':' and followed by the verse number.\n\nFor example, to jump to Surah Al-Baqara Verse #2, type '2:2' into the search field!"), "asset:///images/ic_quran.png" ) ) {}
            else if ( !persist.contains("alFurqanAdvertised") ) {
                definition.source = "AlFurqanAdvertisement.qml";
                var advertisement = definition.createObject();
                advertisement.open();
                persist.saveValueFor("alFurqanAdvertised", 1);
            } else if ( !persist.contains("tutorialVideo") ) {
                var yesClicked = persist.showBlockingDialog( qsTr("Tutorial"), qsTr("Would you like to see a video tutorial on how to use the app?"), qsTr("Yes"), qsTr("No") );
                
                if (yesClicked) {
                    vidTutorial.trigger("bb.action.OPEN");
                }
                
                persist.saveValueFor("tutorialVideo", 1);
            }
        }
    }
    
    SurahPickerPage
    {
        id: pickerPage
        
        actions: [
            ActionItem {
                title: qsTr("Mushaf") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_mushaf.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: LaunchMushaf");
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
        },
        
        Invocation
        {
            id: vidTutorial
            
            query {
                mimeType: "text/html"
                uri: "http://youtu.be/7nA27gIxZ08"
            }
        }
    ]
}