import bb.cascades 1.2

Delegate
{
    property variant data: []
    
    function showNext()
    {
        if (data.length > 0)
        {
            var allData = data;
            var current = allData[allData.length-1];
            object.body = current.body;
            object.icon = current.icon;
        }
    }
    
    onObjectChanged: {
        if (object) {
            showNext();
            object.open();
        }
    }
    
    function init(text, iconUri, plainText)
    {
        if (text.length > 0)
        {
            var allData = data;
            allData.push( {'body': text, 'icon': iconUri, 'plainText': plainText ? plainText : text} );
            data = allData;

            if (!active) {
                active = true;
            } else {
                showNext();
            }
        }
    }
    
    sourceComponent: ComponentDefinition
    {
        Dialog
        {
            id: root
            property alias body: bodyLabel.text
            property alias icon: toastIcon.imageSource
            
            function dismiss()
            {
                if (data.length > 0)
                {
                    var allData = data;
                    allData.pop();
                    data = allData;
                }
                
                if (data.length > 0) {
                    showNext();
                    iconRotate.play();
                } else if ( !fadeOut.isPlaying() ) {
                    fadeOut.play();
                }
            }
            
            onOpened: {
                mainAnim.play();
            }
            
            Container
            {
                id: dialogContainer
                preferredWidth: Infinity
                preferredHeight: Infinity
                background: Color.create(0,0,0,0.5)
                rightPadding: 10; leftPadding: 10
                layout: DockLayout {}
                opacity: 0
                
                onCreationCompleted: {
                    if ( "navigation" in dialogContainer ) {
                        var nav = dialogContainer.navigation;
                        nav.focusPolicy = 0x2;
                        nav.defaultHighlightEnabled = false;
                    }
                }
                
                Container
                {
                    id: toastBg
                    topPadding: 20; leftPadding: 20; rightPadding: 25; bottomPadding: 20
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    background: bg.imagePaint
                    layout: DockLayout {}
                    
                    Container
                    {
                        leftPadding: 60;
                        verticalAlignment: VerticalAlignment.Center
                        
                        ImageView
                        {
                            id: toastIcon
                            verticalAlignment: VerticalAlignment.Center
                            loadEffect: ImageViewLoadEffect.FadeZoom
                            opacity: 0
                            
                            animations: [
                                RotateTransition
                                {
                                    id: iconRotate
                                    fromAngleZ: 0
                                    toAngleZ: 360
                                    duration: 750
                                    easingCurve: StockCurve.QuarticIn
                                }
                            ]
                        }
                    }
                    
                    ScrollView
                    {
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        
                        Container
                        {
                            leftPadding: 160; topPadding: 20; bottomPadding: 30
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            
                            Label
                            {
                                id: bodyLabel
                                multiline: true
                                textStyle.fontSize: FontSize.XSmall
                                textStyle.fontStyle: FontStyle.Italic
                                textStyle.color: Color.Black
                                scaleX: 1.25
                                scaleY: 1.25
                                opacity: 0
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Center
                            }
                        }
                    }
                    
                    attachedObjects: [
                        ImagePaintDefinition {
                            id: bg
                            imageSource: "images/toast/toast_bg.amd"
                        },
                        
                        OrientationHandler {
                            id: rotationHandler
                            
                            onOrientationChanged: {
                                toastBg.maxHeight = orientation == UIOrientation.Portrait ? deviceUtils.pixelSize.height-200 : deviceUtils.pixelSize.width-200;
                            }
                            
                            onCreationCompleted: {
                                orientationChanged(orientation);
                            }
                        }
                    ]
                    
                    contextActions: [
                        ActionSet
                        {
                            subtitle: bodyLabel.text
                            
                            ActionItem
                            {
                                imageSource: "images/menu/ic_copy.png"
                                title: qsTr("Copy") + Retranslate.onLanguageChanged
                                
                                onTriggered: {
                                    console.log("UserEvent: CopyQuote");
                                    persist.copyToClipboard( data[data.length-1].plainText );
                                }
                            }
                            
                            InvokeActionItem
                            {
                                id: shareAction
                                imageSource: "images/menu/ic_share.png"
                                title: qsTr("Share") + Retranslate.onLanguageChanged
                                
                                query {
                                    mimeType: "text/plain"
                                    invokeActionId: "bb.action.SHARE"
                                }
                                
                                onTriggered: {
                                    console.log("UserEvent: ShareQuote");
                                    data = persist.convertToUtf8( data[data.length-1].plainText );
                                }
                            }
                        }
                    ]
                }
                
                gestureHandlers: [
                    TapHandler {
                        onTapped: {
                            console.log("UserEvent: NotificationToastTapped");
                            
                            if ( mainAnim.isPlaying() )
                            {
                                mainAnim.stop();
                                dialogContainer.opacity = dialogFt.toOpacity;
                                toastIcon.opacity = toastIconFt.toOpacity;
                                toastIcon.rotationZ = toastIconRt.toAngleZ;
                                bodyLabel.opacity = bodyLabelFt.toOpacity;
                                bodyLabel.scaleX = bodyLabelSt.toX;
                                bodyLabel.scaleY = bodyLabelSt.toY;
                            } else {
                                root.dismiss();
                            }
                        }
                    }
                ]
            }
            
            onClosed: {
                active = false;
            }
            
            attachedObjects: [
                SequentialAnimation
                {
                    id: mainAnim
                    
                    FadeTransition {
                        id: dialogFt
                        target: dialogContainer
                        fromOpacity: 0
                        toOpacity: 1
                        duration: 250
                        easingCurve: StockCurve.SineOut
                    }
                    
                    ParallelAnimation
                    {
                        FadeTransition
                        {
                            id: toastIconFt
                            fromOpacity: 0
                            toOpacity: 1
                            target: toastIcon
                            duration: 400
                            easingCurve: StockCurve.ExponentialInOut
                        }
                        
                        RotateTransition
                        {
                            id: toastIconRt
                            fromAngleZ: 0
                            toAngleZ: 360
                            target: toastIcon
                            duration: 500
                            delay: 250
                            easingCurve: StockCurve.CubicInOut
                        }
                    }
                    
                    ParallelAnimation
                    {
                        target: bodyLabel

                        FadeTransition
                        {
                            id: bodyLabelFt
                            fromOpacity: 0
                            toOpacity: 1
                            duration: 250
                            easingCurve: StockCurve.QuadraticOut
                        }
                        
                        ScaleTransition
                        {
                            id: bodyLabelSt
                            fromX: 1.2
                            fromY: 1.2
                            toX: 1
                            toY: 1
                            duration: 500
                            easingCurve: StockCurve.ElasticOut
                        }
                    }
                },
                
                ParallelAnimation
                {
                    id: fadeOut
                    
                    FadeTransition {
                        fromOpacity: 1
                        toOpacity: 0
                        duration: 500
                        easingCurve: StockCurve.QuinticIn
                        target: dialogContainer
                    }
                    
                    TranslateTransition
                    {
                        target: toastBg
                        fromY: 0
                        toY: 1000
                        duration: 500
                        easingCurve: StockCurve.ExponentialIn
                    }
                    
                    onEnded: {
                        root.close();
                    }
                }
            ]
        }
    }    
}