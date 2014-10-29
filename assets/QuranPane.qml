import bb.cascades 1.0
import bb.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();

        if (top == pickerPage)
        {
            if ( persist.tutorial( "tutorialAlphanumeric", qsTr("Did you know you can quickly jump to a specific verse by typing its chapter number followed by a ':' and followed by the verse number.\n\nFor example, to jump to Surah Al-Baqara Verse #2, type '2:2' into the search field!"), "asset:///images/ic_quran.png" ) ) {}
            else if ( !persist.contains("shaddaTutorial") ) {
                definition.source = "ShaddaTutorial.qml";
                var shadda = definition.createObject();
                shadda.open();
            } else if ( !persist.contains("alFurqanAdvertised") ) {
                definition.source = "AlFurqanAdvertisement.qml";
                var advertisement = definition.createObject();
                advertisement.open();
                persist.saveValueFor("alFurqanAdvertised", 1, false);
            } else if ( persist.tutorialVideo("http://youtu.be/7nA27gIxZ08") ) {}
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
    
    onCreationCompleted: {
        ds.load();
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        },
        
        DataSource {
            id: ds
            //source: "file:///accounts/1000/shared/misc/quran_arabic.db"
            source: "file:///accounts/1000/shared/misc/quran-data.xml"
            
            onDataLoaded: {
                var all = data.juzs.juz;
                console.log("***", all);
                
                for (var i = 0; i < all.length; i++)
                {
                    helper.apply("INSERT INTO juzs (id,surah_id,verse_number) VALUES(%1,%2,%3)".arg(all[i].index).arg(all[i].sura).arg(all[i].aya) );
                    console.log("INPUTTING")
                }
                
                console.log("****", data.suras, data.hizbs, data.manzils, data.rukus, data.sajdas);
            }
        }
    ]
}