import bb.cascades 1.0

Container
{
    attachedObjects: [
        ImagePaintDefinition {
            id: back
            imageSource: "asset:///images/title_bg.png"
        }
    ]
    
    background: back.imagePaint
    topPadding: 20; leftPadding: 20; rightPadding: 20
    
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    
    layout: DockLayout {}

    Container
    {
	    horizontalAlignment: HorizontalAlignment.Fill
	    verticalAlignment: VerticalAlignment.Center

        ImageView {
            imageSource: "asset:///images/logo.png"
            topMargin: 0
            leftMargin: 0
            rightMargin: 0
            bottomMargin: 0
            horizontalAlignment: HorizontalAlignment.Center
        }
    }
}