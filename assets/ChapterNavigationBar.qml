import bb.cascades 1.3

Container
{
    property int chapterNumber
    signal navigationTapped(bool right);
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
            
            onAnimationFinished: {
                tutorial.execBelowTitleBar("surahNavigation", qsTr("Tap the right arrow to navigate to the next chapter."), 0, "r" );
                tutorial.execBelowTitleBar("navigateSurahLeft", qsTr("Tap the left arrow to navigate to the previous chapter."), 0, "l" );
                tutorial.execBelowTitleBar("follow", qsTr("Use the follow button at the center of the left/right buttons if you want to follow the verses automatically as they are being recited.") );
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