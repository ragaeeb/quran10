import bb.cascades 1.0

Sheet
{
    id: root
    
    Page
    {
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        actions: [
            ActionItem
            {
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                imageSource: "images/list/site_twitter.png"
                title: qsTr("Twitter") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: AlFurqanTwitter");
                    persist.openUri("https://twitter.com/AlFurqanArabic");
                    
                    reporter.record("AlFurqanTwitter");
                }
            },
            
            ActionItem
            {
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "images/list/site_facebook.png"
                title: qsTr("Facebook") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: AlFurqanFacebook");
                    persist.openUri("https://www.facebook.com/AlFurqanArabicMakkah");
                    
                    reporter.record("AlFurqanFacebook");
                }
            },
            
            ActionItem
            {
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "images/list/ic_email.png"
                title: qsTr("Email") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: AlFurqanEmail");
                    persist.invoke("", "", "", "mailto:alfurqanarabic1@gmail.com");
                    
                    reporter.record("AlFurqanEmail");
                }
            }
        ]
        
        titleBar: TitleBar
        {
            title: qsTr("Learn Arabic!") + Retranslate.onLanguageChanged
            
            acceptAction: ActionItem
            {
                imageSource: "file:///usr/share/icons/ic_start_bbm_chat.png"
                title: qsTr("BBM") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: AlFurqanBBM");
                    persist.invoke("", "", "", "pin:55C89DD5");
                    
                    reporter.record("AlFurqanBBM");
                }
            }
            
            dismissAction: ActionItem
            {
                title: qsTr("Back") + Retranslate.onLanguageChanged
                imageSource: "images/title/ic_prev.png"
                
                onTriggered: {
                    console.log("UserEvent: AlFurqanBack");
                    persist.setFlag("alFurqanAdvertised", 1);
                    
                    reporter.record("AlFurqanBack");
                    root.close();
                }
            }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: Color.White
            layout: DockLayout {}
            
            ScrollView
            {
                id: scrollView
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                scrollViewProperties.scrollMode: ScrollMode.Both
                scrollViewProperties.pinchToZoomEnabled: true
                scrollViewProperties.initialScalingMethod: ScalingMethod.AspectFill
                
                WebView
                {
                    id: webView
                    settings.zoomToFitEnabled: true
                    settings.activeTextEnabled: false
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    url: "http://canadainc.org/hosting/alfurqan/al_furqan_logo.jpg"
                    
                    onLoadProgressChanged: {
                        progressIndicator.value = loadProgress;
                    }
                    
                    onLoadingChanged: {
                        if (loadRequest.status == WebLoadStatus.Started) {
                            progressIndicator.visible = true;
                            progressIndicator.state = ProgressIndicatorState.Progress;
                        } else if (loadRequest.status == WebLoadStatus.Succeeded) {
                            progressIndicator.visible = false;
                            progressIndicator.state = ProgressIndicatorState.Complete;
                        } else if (loadRequest.status == WebLoadStatus.Failed) {
                            root.close();
                        }
                    }
                }
            }
            
            ProgressIndicator
            {
                id: progressIndicator
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                value: 0
                fromValue: 0
                toValue: 100
                opacity: value/100
                state: ProgressIndicatorState.Pause
            }
        }
    }
    
    onClosed: {
        destroy();
    }
}