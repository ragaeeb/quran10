import bb.cascades 1.0
import com.canadainc.data 1.0

TitleBar
{
    id: titleControl
    property int chapterNumber
    property alias titleText: surahNameArabic.text
    property alias subtitleText: surahNameEnglish.text
    property variant bgSource: "images/title_bg_tafseer.amd"
    property double bottomPad: 25
    
    onChapterNumberChanged: {
        helper.fetchSurahHeader(titleControl, chapterNumber);
    }
    
    kind: TitleBarKind.FreeForm
    kindProperties: FreeFormTitleBarKindProperties
    {
        content: Container
        {
            topPadding: 10; bottomPadding: bottomPad
            
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Top
            background: back.imagePaint
            
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
        }
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchSurahHeader) {
            surahNameArabic.text = data[0].arabic_name;
            surahNameEnglish.text = qsTr("%1 (%2)").arg(data[0].english_name).arg(data[0].english_translation);
        }
    }
}