import bb.cascades 1.2
import bb.system 1.0
import com.canadainc.data 1.0

ListView
{
    id: listView
    property alias theDataModel: verseModel
    property int chapterNumber
    property int translationSize: helper.translationSize
    property int primarySize: helper.primarySize
    property alias custom: customTextStyle
    
    dataModel: ArrayDataModel {
        id: verseModel
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
                var current = verseModel.data(indexPath);
                varModel.updateItem(indexPath, current);
            }
        }
    }
    
    attachedObjects: [
        
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
        ListItemComponent {
            AyatListItem {}
        }
    ]
}