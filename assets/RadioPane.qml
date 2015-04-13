import bb.cascades 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        id: mainPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        shortcuts: [
            SystemShortcut {
                type: SystemShortcuts.ScrollDownOneScreen
                
                onTriggered: {
                    dropDown.expanded = true;
                }
            }
        ]
        
        titleBar: TitleBar {
            title: qsTr("Radio") + Retranslate.onLanguageChanged
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            leftPadding: 10; rightPadding: 10; topPadding: 10;
            
            DropDown
            {
                id: dropDown
                title: qsTr("Channel") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                
                Option {
                    id: offOption
                    imageSource: "images/dropdown/ic_off.png"
                    text: qsTr("Off") + Retranslate.onLanguageChanged
                    selected: true
                }

                Option {
                    imageSource: "images/dropdown/ic_radio_channel.png"
                    text: qsTr("The Quran Radio") + Retranslate.onLanguageChanged
                    description: qsTr("Wakas Mir Networks") + Retranslate.onLanguageChanged
                    
                    onSelectedChanged:
                    {
                        if (selected) {
                            contentDelegate.uri = "http://50.22.217.209:9998/;stream.nsv&type=mp3&volume=100&autostart=true";
                        }
                    }
                }
                
                Option {
                    imageSource: "images/dropdown/ic_radio_channel.png"
                    text: qsTr("Radio Quraan") + Retranslate.onLanguageChanged
                    description: qsTr("www.radioquraan.com") + Retranslate.onLanguageChanged
                    
                    onSelectedChanged:
                    {
                        if (selected) {
                            contentDelegate.uri = "http://66.45.232.131:9994/;stream.nsv&type=mp3&volume=100&autostart=true";
                        }
                    }
                }

                onSelectedOptionChanged: {
                    contentDelegate.delegateActive = selectedOption != offOption;
                }
            }
            
            ControlDelegate
            {
                id: contentDelegate
                delegateActive: false
                property variant uri
                property string html
                
                sourceComponent: ComponentDefinition
                {
                    Container
                    {
                        layout: DockLayout {}
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        
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
                                settings.activeTextEnabled: true
                                preferredHeight: 200
                                html: contentDelegate.html ? contentDelegate.html : undefined
                                url: contentDelegate.uri ? contentDelegate.uri : undefined
                                
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
                                        html = "<html><head><title>Load Fail</title><style>* { margin: 0px; padding 0px; }body { font-size: 48px; font-family: monospace; border: 1px solid #444; padding: 4px; }</style> </head> <body>Loading failed! Please check your internet connection.</body></html>"
                                        progressIndicator.visible = false;
                                        progressIndicator.state = ProgressIndicatorState.Error;
                                    }
                                }
                            }
                        }
                        
                        ProgressIndicator {
                            id: progressIndicator
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Top
                            visible: true
                            value: 0
                            fromValue: 0
                            toValue: 100
                            state: ProgressIndicatorState.Pause
                        }
                    }
                }
            }
        }
    }
    
    onCreationCompleted: {
        if ( tutorialToast.tutorial( "tutorialRadio", qsTr("These are some of the stations where they continuously stream Qu'ran. Be careful though, this uses data. Be sure to be on a proper wireless network."), "images/tabs/ic_radio.png" ) ) {}
    }
}