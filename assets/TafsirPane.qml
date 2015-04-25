import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane

    onPopTransitionEnded: {
        page.destroy();
    }
    
    function onCreate(id, author, translator, explainer, title, description, reference)
    {
        tafsirHelper.addTafsir(navigationPane, author, translator, explainer, title, description, reference);
        
        while (navigationPane.top != tafsirPicker) {
            navigationPane.pop();
        }
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.AddTafsir)
        {
            persist.showToast( qsTr("Tafsir added!"), "images/menu/ic_add_suite.png" );
            tafsirPicker.reload();
        }
    }
    
    TafsirPickerPage
    {
        id: tafsirPicker
        
        onTafsirPicked: {
            var page = global.createObject("TafsirContentsPage.qml");
            page.title = data.title;
            page.suiteId = data.id;
            
            navigationPane.push(page);
        }
        
        actions: [
            ActionItem
            {
                imageSource: "images/menu/ic_add_suite.png"
                title: qsTr("Add") + Retranslate.onLanguageChanged
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: NewSuite");
                    var page = global.createObject("CreateTafsirPage.qml");
                    page.createTafsir.connect(onCreate);
                    
                    navigationPane.push(page);
                }
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.CreateNew
                    }
                ]
            }
        ]
    }
}