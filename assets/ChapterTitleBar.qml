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
    property bool showNavigation: false
    property bool navigationExpanded: false
    signal navigationTapped(bool right);
    
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
        
        expandableArea
        {
            expanded: showNavigation && navigationExpanded
            indicatorVisibility: showNavigation ? TitleBarExpandableAreaIndicatorVisibility.Visible : TitleBarExpandableAreaIndicatorVisibility.Hidden
            
            content: ControlDelegate
            {
                delegateActive: showNavigation
                
                sourceComponent: ComponentDefinition
                {
                    Container
                    {
                        background: orangeBg.imagePaint
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        layout: DockLayout {}
                        
                        Container
                        {
                            leftPadding: 10; rightPadding: 10; topPadding: 5; bottomPadding: 5
                            background: Color.create(0.0, 0.0, 0.0, 0.5)
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            
                            NavigationButton
                            {
                                defaultImageSource: "images/backgrounds/ic_prev.png"
                                enabled: chapterNumber > 1
                                
                                onClicked: {
                                    navigationTapped(false);
                                }
                            }
                            
                            Container
                            {
                                horizontalAlignment: HorizontalAlignment.Fill
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                            
                            NavigationButton
                            {
                                horizontalAlignment: HorizontalAlignment.Right
                                defaultImageSource: "images/backgrounds/ic_next.png"
                                enabled: chapterNumber < 114
                                multiplier: -1
                                
                                onClicked: {
                                    navigationTapped(true);
                                }
                            }
                            
                            attachedObjects: [
                                ImagePaintDefinition {
                                    id: orangeBg
                                    imageSource: "images/title_bg.png"
                                }
                            ]
                        }
                    }
                }
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