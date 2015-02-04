import bb.cascades 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();
        
        if ( persist.tutorialVideo("http://youtu.be/7nA27gIxZ08") ) {}
        else if ( tutorialToast.tutorial( "tutorialAlphanumeric", qsTr("Did you know you can quickly jump to a specific verse by typing its chapter number followed by a ':' and followed by the verse number.\n\nFor example, to jump to Surah Al-Baqara Verse #2, type '2:2' into the search field!"), "images/ic_quran.png" ) ) {}
        else if ( !persist.contains("alFurqanAdvertised") ) {
            definition.source = "AlFurqanAdvertisement.qml";
            var advertisement = definition.createObject();
            advertisement.open();
            persist.saveValueFor("alFurqanAdvertised", 1, false);
        }
    }
    
    SurahPickerPage
    {
        id: pickerPage
        showJuz: true

        pickerList.onSelectionChanged: {
            var n = pickerList.selectionList().length;
            compareAction.enabled = n > 1 && n < 5;
            pickerList.multiSelectHandler.status = qsTr("%n chapters selected", "", n);
        }
        
        pickerList.multiSelectAction: MultiSelectActionItem {
            imageSource: "images/menu/ic_select_more_chapters.png"
        }

        pickerList.multiSelectHandler.actions: [
            ActionItem
            {
                id: compareAction
                enabled: false
                imageSource: "images/menu/ic_compare.png"
                title: qsTr("Compare") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: CompareSurahs");
                    definition.source = "CompareSurahsPage.qml";
                    var p = definition.createObject();
                    
                    var all = pickerPage.pickerList.selectionList();
                    var surahIds = [];
                    
                    for (var i = all.length-1; i >= 0; i--) {
                        surahIds.push( pickerPage.pickerList.dataModel.data(all[i]).surah_id );
                    }
                    
                    p.surahIds = surahIds;
                    navigationPane.push(p);
                }
            }
        ]
        
        actions: [
            ActionItem {
                title: qsTr("Mushaf") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_mushaf.png"
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                
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
        
        onCreationCompleted: {
            app.lazyInitComplete.connect(ready);
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}