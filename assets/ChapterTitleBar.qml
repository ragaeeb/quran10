import bb.cascades 1.0
import com.canadainc.data 1.0

TitleBar
{
    id: titleControl
    property int chapterNumber
    property alias bgAsset: back.imageSource
    property alias text: surahNameArabic.text
    signal titleTapped();
    
    onChapterNumberChanged: {
        helper.fetchSurahHeader(titleControl, chapterNumber);
    }
    
    kind: TitleBarKind.FreeForm
    kindProperties: FreeFormTitleBarKindProperties
    {
        content: Container
        {
            id: titleContainer
            topPadding: 10; bottomPadding: 10
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: back.imagePaint
            
            onCreationCompleted: {
                if ( "navigation" in titleContainer ) {
                    var nav = titleContainer.navigation;
                    nav.focusPolicy = 0x2;
                }
            }
            
            gestureHandlers: [
                TapHandler {
                    onTapped: {
                        console.log("UserEvent: ChapterTitleTapped");
                        titleTapped();
                    }
                }
            ]
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: back
                    imageSource: "images/title/title_bg_alt.png"
                }
            ]
            
            Label {
                id: surahNameArabic
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.XXSmall
                textStyle.fontWeight: FontWeight.Bold
                multiline: true
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
            }
        }
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchSurahHeader)
        {
            var surahName = data[0].name;
            
            if (helper.showTranslation) {
                surahName += "\n"+qsTr("%1 (%2)").arg(data[0].transliteration).arg(data[0].translation);
            }
            
            surahNameArabic.text = surahName;
        }
    }
}