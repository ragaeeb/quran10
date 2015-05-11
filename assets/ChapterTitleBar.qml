import bb.cascades 1.3
import com.canadainc.data 1.0

TitleBar
{
    id: titleControl
    property int chapterNumber
    property alias text: surahNameArabic.text
    signal titleTapped();
    signal navigationTapped(bool right);

    onChapterNumberChanged: {
        if (chapterNumber > 0)
        {
            helper.fetchSurahHeader(titleControl, chapterNumber);
            prev.enabled = chapterNumber > 1;
            next.enabled = chapterNumber < 114;
        }
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
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}

            Container
            {
                id: titleContainer
                leftPadding: 10; rightPadding: 10; topPadding: 20
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
                    verticalAlignment: VerticalAlignment.Center
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

            Container
            {
                id: prevContainer
                verticalAlignment: VerticalAlignment.Center
                leftPadding: 10

                NavigationButton
                {
                    id: prev
                    defaultImageSource: "images/title/ic_prev.png"
                    disabledImageSource: "images/title/ic_prev_disabled.png"
                    verticalAlignment: VerticalAlignment.Center

                    onClicked: {
                        navigationTapped(false);
                    }
                }
            }
            
            Container
            {
                id: nextContainer
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
                rightPadding: 10
                
                NavigationButton
                {
                    id: next
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Center
                    defaultImageSource: "images/title/ic_next.png"
                    disabledImageSource: "images/title/ic_next_disabled.png"
                    multiplier: -1
                    
                    onClicked: {
                        navigationTapped(true);
                    }
                    
                    onAnimationFinished: {
                        tutorial.exec("surahNavigation", qsTr("Tap the right arrow to navigate to the next chapter."), HorizontalAlignment.Right, VerticalAlignment.Top );
                        tutorial.exec("navigateSurahLeft", qsTr("Tap the left arrow to navigate to the previous chapter."), HorizontalAlignment.Left, VerticalAlignment.Top );
                    }
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
                surahName = "%1 (%2)".arg(data[0].transliteration).arg(data[0].translation);
            }
            
            surahNameArabic.text = surahName;
        }
    }
}