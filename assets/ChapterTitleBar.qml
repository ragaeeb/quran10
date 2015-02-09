import bb.cascades 1.0
import com.canadainc.data 1.0

TitleBar
{
    id: titleControl
    property int chapterNumber
    property alias titleText: surahNameArabic.text
    property alias subtitleText: surahNameEnglish.text
    property variant bgSource: "images/title/title_bg_tafseer.amd"
    property double bottomPad: 25
    property bool showNavigation: false
    property bool navigationExpanded: false
    signal navigationTapped(bool right);
    scrollBehavior: TitleBarScrollBehavior.NonSticky
    
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
                                defaultImageSource: "images/title/ic_prev.png"
                                disabledImageSource: "images/title/ic_prev_disabled.png"
                                enabled: chapterNumber > 1
                                
                                onClicked: {
                                    navigationTapped(false);
                                }
                            }
                            
                            Container
                            {
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                                
                                ImageToggleButton
                                {
                                    checked: persist.getValueFor("follow") == 1
                                    imageSourceChecked: "images/title/ic_follow_on.png"
                                    imageSourceDefault: "images/title/ic_follow_off.png"
                                    imageSourcePressedChecked: imageSourceDefault
                                    imageSourcePressedUnchecked: imageSourceChecked
                                    horizontalAlignment: HorizontalAlignment.Center
                                    
                                    onCheckedChanged: {
                                        persist.saveValueFor("follow", checked ? 1 : 0);
                                    }
                                }
                            }
                            
                            NavigationButton
                            {
                                horizontalAlignment: HorizontalAlignment.Right
                                defaultImageSource: "images/title/ic_next.png"
                                disabledImageSource: "images/title/ic_next_disabled.png"
                                enabled: chapterNumber < 114
                                multiplier: -1
                                
                                onClicked: {
                                    navigationTapped(true);
                                }
                            }
                            
                            attachedObjects: [
                                ImagePaintDefinition {
                                    id: orangeBg
                                    imageSource: "images/title/title_bg.png"
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
        if (id == QueryId.FetchSurahHeader)
        {
            surahNameArabic.text = data[0].name;
            
            if (helper.showTranslation) {
                surahNameEnglish.text = qsTr("%1 (%2)").arg(data[0].transliteration).arg(data[0].translation);
            }
        }
    }
}