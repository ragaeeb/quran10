import bb.cascades 1.0
import com.canadainc.data 1.0

TitleBar
{
    id: titleControl
    property int chapterNumber
    property variant bgSource: "images/title/title_bg_tafseer.amd"
    property double bottomPad: 25
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
            topPadding: 10; bottomPadding: bottomPad
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Top
            background: back.imagePaint
            
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
                    imageSource: bgSource
                }
            ]
            
            Label {
                id: surahNameArabic
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.XXSmall
                textStyle.fontWeight: FontWeight.Bold
                bottomMargin: 5
            }
            
            Label {
                id: surahNameEnglish
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.XXSmall
                textStyle.fontWeight: FontWeight.Bold
                topMargin: 0
            }
            
            onCreationCompleted: {
                if ( "navigation" in titleContainer ) {
                    var nav = titleContainer.navigation;
                    nav.focusPolicy = 0x2;
                }
            }
        }
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchSurahHeader)
        {
            surahNameArabic.text = data[0].name;
            
            if (helper.showTranslation) {
                surahNameEnglish.text = qsTr("%1 (%2)").arg(data[0].transliteration).arg(data[0].translation);
            }
        }
    }
}