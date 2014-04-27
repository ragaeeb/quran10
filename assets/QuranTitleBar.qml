import bb.cascades 1.0

TitleBar
{
    kind: TitleBarKind.FreeForm
    kindProperties: FreeFormTitleBarKindProperties
    {
        Container
        {
            id: titleBar
            background: titleBack.imagePaint
            rightPadding: 50
            layout: DockLayout {}
            
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Top
            
            ImageView {
                imageSource: "images/title/logo.png"
                topMargin: 0
                leftMargin: 0
                rightMargin: 0
                bottomMargin: 0
                loadEffect: ImageViewLoadEffect.FadeZoom
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
                
                animations: [
                    FadeTransition {
                        id: fadeInLogo
                        easingCurve: StockCurve.CubicIn
                        fromOpacity: 0
                        toOpacity: 1
                        duration: 1000
                    }
                ]
                
                onCreationCompleted: {
                    fadeInLogo.play();
                }
            }
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: titleBack
                    imageSource: "images/title/title_bg.png"
                }
            ]
        }
    }
}