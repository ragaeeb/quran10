import bb.cascades 1.3

Delegate
{
    id: tutorialDelegate
    property variant data: []
    property variant keys: {}
    property int currentIndex: -1
    signal tutorialFinished(string key)
    
    function count() {
        return data.length;
    }
    
    function showNext()
    {
        if (currentIndex < data.length)
        {
            ++currentIndex;
            var current = data[currentIndex];
            object.apply(current);
        }
    }
    
    onObjectChanged: {
        if (object)
        {
            showNext();
            object.open();
        }
    }
    
    function isTopPane(navPane, p) {
        return navPane.parent.parent.activePane == navPane && navPane.top == p;
    }
    
    function execBelowTitleBar(key, text, topPadding, pos, type, imageSource)
    {
        var ui = Application.scene.ui;
        
        if (!topPadding) {
            topPadding = 0;
        }

        return exec( key, text, pos == "l" ? HorizontalAlignment.Left : pos == "r" ? HorizontalAlignment.Right : HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, ui.du(14) + topPadding, 0, imageSource, type );
    }
    
    function execCentered(key, text, imageSource)
    {
        return exec(key, text, HorizontalAlignment.Center, VerticalAlignment.Center, 0, 0, 0, 0, imageSource);
    }
    
    function execActionBar(key, text, pos)
    {
        var ui = Application.scene.ui;
        
        return exec( key, text, pos == "x" ? HorizontalAlignment.Right : HorizontalAlignment.Center, VerticalAlignment.Bottom, pos == "r" ? ui.du(31) : 0, pos == "l" ? ui.du(31) : 0, 0, ui.du(2) );
    }
    
    function exec(key, text, h, v, left, right, top, bottom, imageUri, type)
    {
        if (key) {
            key = "tutorial" + key.charAt(0).toUpperCase() + key.slice(1);
        }
        
        if ( text.length > 0 && !persist.suppressTutorials && ( !key || !persist.contains(key) ) )
        {
            var allKeys = keys;
            
            if ( key && !(key in allKeys) )
            {
                var allData = data;
                allData.push( {'key': key, 'body': text, 'icon': imageUri, 'h': h, 'v': v, 'l': left, 'r': right, 't': top, 'b': bottom, 'type': type} );
                data = allData;
                
                if (key) {
                    allKeys[key] = allData.length-1;
                    keys = allKeys;
                }
                
                if (!active) {
                    active = true;
                }
            }
            
            return true;
        }
        
        return false;
    }
    
    sourceComponent: ComponentDefinition
    {
        Dialog
        {
            id: fsd
            property variant current: {}
            
            function apply(d)
            {
                swipeAnim.stop();
                
                current = d;
                swipeBar.visible = false;
                assetContainer.resetTranslation();
                assetContainer.horizontalAlignment = current.h != undefined ? current.h : HorizontalAlignment.Center;
                assetContainer.verticalAlignment = current.v != undefined ? current.v : VerticalAlignment.Center;
                bodyControl.text = current.body;
                bodyLabel.verticalAlignment = assetContainer.horizontalAlignment == HorizontalAlignment.Center && assetContainer.verticalAlignment == VerticalAlignment.Center ? VerticalAlignment.Top : VerticalAlignment.Center
                icon.imageSource = current.icon ? current.icon : "images/tutorial/pointer.png";
                
                swipeAnim.resetFromY();
                swipeAnim.resetToY();
                swipeAnim.resetFromX();
                swipeAnim.resetToX();
                
                if (current.type == "r")
                {
                    swipeBar.visible = true;
                    swipeAnim.fromX = -ui.du(2);
                    swipeAnim.toX = ui.du(45);
                    swipeAnim.play();
                } else if (current.type == "d") {
                    swipeAnim.fromY = -ui.du(2);
                    swipeAnim.toY = ui.du(45);
                    swipeAnim.play();
                }
            }
            
            function dismiss()
            {
                var key = current.key;
                
                if (key && key.length > 0)
                {
                    persist.saveValueFor(key, 1, false);
                    
                    key = key.substring("tutorial".length);
                    key = key.charAt(0).toLowerCase() + key.slice(1);
                    tutorialFinished(key);
                }
                
                if (currentIndex < data.length-1) {
                    showNext();
                } else if ( !fadeOut.isPlaying() ) {
                    fadeOut.play();
                }
            }
            
            onOpened: {
                mainAnim.play();
            }
            
            onClosed: {
                active = false;
            }
            
            onCreationCompleted: {
                open();
            }
            
            Container
            {
                id: dialogContainer
                preferredWidth: Infinity
                preferredHeight: Infinity
                background: Color.create(0.0, 0.0, 0.0, 0.7)
                layout: DockLayout {}
                opacity: 0
                
                contextActions: [
                    ActionSet
                    {
                        title: qsTr("Stop all Tutorials") + Retranslate.onLanguageChanged
                        subtitle: qsTr("Prevent any tutorials from showing...") + Retranslate.onLanguageChanged
                        
                        DeleteActionItem
                        {
                            id: dai
                            imageSource: "images/bugs/ic_bugs_cancel.png"
                            title: qsTr("Suppress Tutorials") + Retranslate.onLanguageChanged
                            
                            function onFinished(confirmed)
                            {
                                if (confirmed)
                                {
                                    persist.suppressTutorials = true;
                                    data = [];
                                    keys = {};
                                    fsd.dismiss();
                                }
                            }
                            
                            onTriggered: {
                                console.log("UserEvent: SuppressTutorials");
                                persist.showDialog( dai, qsTr("Suppress Tutorials"), qsTr("Are you sure you want to prevent all further tutorials? If you ever want to enable them again, swipe-down from the top-bezel, go to Help, tap on the title bar and uncheck the 'Suppress Tutorials' checkmark.") );
                            }
                        }
                    }
                ]
                
                gestureHandlers: [
                    TapHandler
                    {
                        onTapped: {
                            console.log("UserEvent: TutorialTapped");
                            
                            if ( mainAnim.isPlaying() )
                            {
                                mainAnim.stop();
                                dialogContainer.opacity = dialogFt.toOpacity;
                                assetContainer.opacity = toastIconFt.toOpacity;
                                assetContainer.scaleX = assetContainer.scaleX;
                                assetContainer.scaleY = assetContainer.scaleY;
                                bodyLabel.opacity = bodyLabelFt.toOpacity;
                                bodyLabel.scaleX = bodyLabelSt.toX;
                                bodyLabel.scaleY = bodyLabelSt.toY;
                            } else {
                                fsd.dismiss();
                            }
                        }
                    }
                ]
                
                animations: [
                    FadeTransition
                    {
                        id: fadeOut
                        fromOpacity: 1
                        toOpacity: 0
                        duration: 500
                        easingCurve: StockCurve.QuinticIn
                        target: dialogContainer
                        
                        onEnded: {
                            fsd.close();
                        }
                    }
                ]
                
                Container
                {
                    layout: DockLayout {}
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    ImageView
                    {
                        id: swipeBar
                        imageSource: "images/tutorial/swipe_bar.png"
                        loadEffect: ImageViewLoadEffect.FadeZoom
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: assetContainer.verticalAlignment
                        minHeight: 125
                    }
                    
                    Container
                    {
                        id: assetContainer
                        opacity: 0
                        scaleX: 0
                        scaleY: 0
                        leftPadding: fsd.current.l ? fsd.current.l : 0;
                        rightPadding: fsd.current.r ? fsd.current.r : 0;
                        bottomPadding: fsd.current.b ? fsd.current.b+iconLuh.layoutFrame.height/2 : 0;
                        topPadding: fsd.current.t ? fsd.current.t-iconLuh.layoutFrame.height/2 : 0;
                        
                        ImageView
                        {
                            id: icon
                            loadEffect: ImageViewLoadEffect.FadeZoom
                            
                            attachedObjects: [
                                LayoutUpdateHandler {
                                    id: iconLuh
                                }
                            ]
                            
                            onCreationCompleted: {
                                if ( "navigation" in icon ) {
                                    var nav = icon.navigation;
                                    nav.focusPolicy = 0x2;
                                    nav.defaultHighlightEnabled = false;
                                }
                            }
                        }
                        
                        animations: [
                            ParallelAnimation
                            {
                                id: breathe
                                repeatCount: AnimationRepeatCount.Forever
                                
                                SequentialAnimation
                                {
                                    ScaleTransition {
                                        fromX: 1
                                        toX: 1.2
                                        fromY: 1
                                        toY: 1.2
                                        easingCurve: StockCurve.ExponentialOut
                                        duration: 750
                                    }
                                    
                                    ScaleTransition {
                                        fromX: 1.2
                                        toX: 1
                                        fromY: 1.2
                                        toY: 1
                                        easingCurve: StockCurve.ExponentialIn
                                        duration: 750
                                    }
                                }
                            },
                            
                            TranslateTransition
                            {
                                id: swipeAnim
                                repeatCount: AnimationRepeatCount.Forever
                                easingCurve: StockCurve.ExponentialOut
                                duration: 2000
                                delay: 500
                            }
                        ]
                    }
                    
                    Container
                    {
                        id: bodyLabel
                        scaleX: 1.25
                        scaleY: 1.25
                        opacity: 0
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Center
                        leftPadding: 10; rightPadding: 10; topPadding: 10; bottomPadding: 10
                        
                        Label
                        {
                            id: bodyControl
                            textStyle.color: Color.White
                            textStyle.fontStyle: FontStyle.Italic
                            textStyle.textAlign: TextAlign.Center
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Center
                            multiline: true
                        }
                    }
                }
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
                            toOpacity: 0.7
                            target: assetContainer
                            duration: 400
                            easingCurve: StockCurve.ExponentialInOut
                        }
                        
                        ScaleTransition
                        {
                            id: toastIconRt
                            fromX: 0
                            toX: 1
                            fromY: 0
                            toY: 1
                            target: assetContainer
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
                    
                    onEnded: {
                        breathe.play();
                    }
                }
            ]
        }
    }
}