import bb.cascades 1.0

Page {
    property alias contentContainer: contentContainer.controls

    Container {
        attachedObjects: [
            ImagePaintDefinition {
                id: back
                imageSource: "asset:///images/background.png"
            }
        ]
        
		background: back.imagePaint
		horizontalAlignment: HorizontalAlignment.Fill
		verticalAlignment: VerticalAlignment.Fill
        
		Container
		{
		    id: titleBar
		    layout: DockLayout {}
		
		    horizontalAlignment: HorizontalAlignment.Fill
		    verticalAlignment: VerticalAlignment.Top
		    
		    ImageView {
		        imageSource: "asset:///images/title_bg.png"
		        topMargin: 0
		        leftMargin: 0
		        rightMargin: 0
		        bottomMargin: 0
		
		        horizontalAlignment: HorizontalAlignment.Fill
		        verticalAlignment: VerticalAlignment.Top
		        
		        animations: [
		            TranslateTransition {
		                id: translate
		                toY: 0
		                fromY: -100
		                duration: 1000
		            }
		        ]
		        
		        onCreationCompleted:
		        {
		            if ( app.getValueFor("animations") == 1 ) {
		                translate.play()
		            }
		        }
		    }

            Container
            {
		        horizontalAlignment: HorizontalAlignment.Right
		        verticalAlignment: VerticalAlignment.Center
		        rightPadding: 50
                
			    ImageView {
			        imageSource: "asset:///images/logo.png"
			        topMargin: 0
			        leftMargin: 0
			        rightMargin: 0
			        bottomMargin: 0
			
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
			        
			        onCreationCompleted:
			        {
			            if ( app.getValueFor("animations") == 1 ) {
                            fadeInLogo.play()
			            }
			        }
			    }
            }
		}
		
		Container {
		    background: Color.White
		    preferredHeight: 2; minHeight: 2; maxHeight: 2
		}

        Container // This container is replaced
        {
            layout: DockLayout {
                
            }
            
            id: contentContainer
            objectName: "contentContainer"
            
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill

            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
            
            ImageView {
                imageSource: "asset:///images/bottomDropShadow.png"
                topMargin: 0
                leftMargin: 0
                rightMargin: 0
                bottomMargin: 0

                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Top
                
                animations: [
                    TranslateTransition {
                        id: translateShadow
                        toY: 0
                        fromY: -100
                        duration: 1000
                    }
                ]
                
		        onCreationCompleted:
		        {
		            if ( app.getValueFor("animations") == 1 ) {
		                translateShadow.play()
		            }
		        }
            }
        }
    }
}