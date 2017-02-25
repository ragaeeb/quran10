import bb.cascades 1.2

HelpPage
{
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    videoTutorialUri: "http://youtu.be/YOXtjnNWVZM"

    Container
    {
        leftPadding: 10; rightPadding: 10; topPadding: 10
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Fill
        
        ImageView
        {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            imageSource: "images/title/logo.png"
        }
    }
}