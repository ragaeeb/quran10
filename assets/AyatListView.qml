import bb.cascades 1.2
import bb.system 1.0
import com.canadainc.data 1.0

ListView
{
    id: listView
    property alias theDataModel: verseModel
    property alias background: headerBackground
    property int chapterNumber
    property int translationSize: helper.translationSize
    property int primarySize: helper.primarySize
    property alias custom: customTextStyle
    
    dataModel: GroupDataModel
    {
        id: verseModel
        sortingKeys: [ "verse_id" ]
        grouping: ItemGrouping.ByFullValue
    }
    
    leadingVisual: BismillahControl {
        delegateActive: chapterNumber > 1 && chapterNumber != 9
    }
    
    function refresh()
    {
        var sections = verseModel.childCount([]);
        
        for (var i = 0; i < sections; i++)
        {
            var childrenInSection = verseModel.childCount([i]);
            
            for (var j = 0; j < childrenInSection; j++)
            {
                var indexPath = [i,j];
                var current = verseModel.data(indexPath).toMap();
                varModel.updateItem(indexPath, current);
            }
        }
    }
    
    attachedObjects: [
        ImagePaintDefinition
        {
            id: headerBackground
            imageSource: "images/backgrounds/header_bg.png"
        },
        
        TextStyleDefinition
        {
            id: customTextStyle
            
            rules: [
                FontFaceRule {
                    id: baseStyleFontRule
                    source: "fonts/me_quran.ttf"
                    fontFamily: "Regular"
                }
            ]
        }
    ]
    
    listItemComponents: [
        ListItemComponent
        {
            type: "header"
            
            AyatHeaderListItem {
                id: headerRoot
                labelValue: qsTr("%1:%2").arg(headerRoot.ListItem.view.chapterNumber).arg(ListItemData)
            }
        },
        
        ListItemComponent
        {
            type: "item"
            
            AyatListItem {}
        }
    ]
}