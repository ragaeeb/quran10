import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane

    onPopTransitionEnded: {
        page.destroy();
    }
    
    function onCreate(author, translator, explainer, title, description, reference)
    {
        helper.addTafsir(navigationPane, author, translator, explainer, title, description, reference);
        
        while (navigationPane.top != tafsirPicker) {
            navigationPane.pop();
        }
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.AddTafsir)
        {
            persist.showToast( qsTr("Tafsir added!"), "", "asset:///images/list/ic_tafsir.png" );
            tafsirPicker.reload();
        }
    }
    
    TafsirPickerPage
    {
        id: tafsirPicker
        
        onTafsirPicked: {
            definition.source = "TafsirContentsPage.qml";
            var page = definition.createObject();
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
                    definition.source = "CreateTafsirPage.qml";
                    var page = definition.createObject();
                    page.createTafsir.connect(onCreate);
                    
                    navigationPane.push(page);
                }
            }
        ]
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}