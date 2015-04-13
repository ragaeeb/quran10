import bb.cascades 1.3
import com.canadainc.data 1.0

TitleBar
{
    id: titleControl
    property int chapterNumber
    property alias text: surahNameArabic.text
    signal titleTapped();
    
    onChapterNumberChanged: {
        helper.fetchSurahHeader(titleControl, chapterNumber);
    }
    
    onCreationCompleted: {
        helper.textualChange.connect( function() {
            chapterNumberChanged();
        });
        
        tutorial.exec("chapterTitleBar", qsTr("Tap here to open all the explanations for this chapter."), HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, ui.du(5));
    }
    
    kind: TitleBarKind.FreeForm
    kindProperties: FreeFormTitleBarKindProperties
    {
        Container
        {
            id: titleContainer
            leftPadding: 10; rightPadding: 10; topPadding: 10
            background: back.imagePaint
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
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
            
            Label {
                id: surahNameArabic
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
                textStyle.base: SystemDefaults.TextStyles.TitleText
            }
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: back
                    imageSource: "images/title/title_bg_alt.png"
                }
            ]
        }
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchSurahHeader)
        {
            var surahName = data[0].name;
            
            if (helper.showTranslation) {
                surahName = "%1 (%2)".arg(data[0].transliteration).arg(data[0].translation);
            }
            
            surahNameArabic.text = surahName;
        }
    }
}