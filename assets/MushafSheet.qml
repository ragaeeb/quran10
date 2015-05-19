import QtQuick 1.0
import bb.cascades 1.3
import bb.system 1.0
import com.canadainc.data 1.0

Sheet
{
    id: sheet
    peekEnabled: false
    property int currentPage: persist.contains("savedPage") ? persist.getValueFor("savedPage") : 1
    property variant currentImageSource
    
    onCurrentPageChanged: {
        mushaf.requestPage(currentPage);
        
        reporter.record("CurrentMushafPage", currentPage);
    }
    
    function activate()
    {
        hiddenTitle.visibility = ChromeVisibility.Overlay;
        mainPage.actionBarVisibility = ChromeVisibility.Overlay;
        timer.restart();
    }
    
    Page
    {
        id: mainPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        actionBarVisibility: ChromeVisibility.Hidden
        
        onActionMenuVisualStateChanged: {
            if (actionMenuVisualState == ActionMenuVisualState.VisibleFull)
            {
                tutorial.execCentered( "mushafJumpSurah", qsTr("Use the '%1' action to select a specific surah in the mushaf you want to jump to.").arg(jumpSurah.title), "images/menu/ic_jump.png" );
                tutorial.execCentered( "mushafJumpPage", qsTr("Use the '%1' action to jump to a specific page number in the mushaf.").arg(jumpPage.title), "images/dropdown/jump_to_page.png" );
                tutorial.execCentered( "mushafStretch", qsTr("Use the 'Stretch' action to stretch the mushaf page to fill your screen size. Note that this may not always be visually attractive."), "images/menu/ic_stretch.png" );
                tutorial.execCentered( "mushafAspectFill", qsTr("Use the 'Aspect Fill' action to resize the mushaf according to its original dimensions. In this mode you will have to do pinch-and-zoom and pan gestures with your fingers in order to view the different parts of the page."), "images/menu/ic_aspect_fill.png" );
                tutorial.execActionBar( "mushafDownloadAll", qsTr("Quran10 does its best to minimize your data usage by lazily downloading the pages as you need them. However, if you want to download them all at once tap on the '%1' action.").arg(downloadAll.title), "images/menu/ic_download_mushaf.png" );
            }
            
            reporter.record("MushafActionMenu", actionMenuVisualState.toString());
        }
        
        shortcuts: [
            SystemShortcut
            {
                type: SystemShortcuts.PreviousSection
                
                onTriggered: {
                    console.log("UserEvent: PrevPage");
                    prevPage.clicked();
                    reporter.record("PrevPageShortcut");
                }
            },
            
            SystemShortcut
            {
                type: SystemShortcuts.NextSection
                
                onTriggered: {
                    console.log("UserEvent: NextPage");
                    nextPage.clicked();
                    reporter.record("NextPageShortcut");
                }
            }
        ]
        
        actions: [
            ActionItem
            {
                imageSource: "images/ic_quran.png"
                title: qsTr("Back") + Retranslate.onLanguageChanged
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: MushafBack");
                    onAboutToQuit();
                    
                    tutorial.execCentered( "mushafSaveClose", qsTr("The app automatically saves the last page number you left off (Page %1) so you can easily pick up where you left off when you come back.").arg(currentPage), "images/menu/ic_select_more_chapters.png" );
                    
                    sheet.close();
                    
                    reporter.record("MushafBack");
                }
                
                function onAboutToQuit() {
                    persist.saveValueFor("savedPage", currentPage, false);
                }
                
                onCreationCompleted: {
                    Application.aboutToQuit.connect(onAboutToQuit);
                }
            },
            
            ActionItem
            {
                id: jumpSurah
                property variant pageNumbers
                title: qsTr("Surah") + Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "images/menu/ic_jump.png"
                
                onTriggered: {
                    console.log("UserEvent: JumpSurah");
                    hiddenTitle.visibility = ChromeVisibility.Hidden;
                    persist.invoke("com.canadainc.Quran10.surah.picker");
                    timer.stop();
                    
                    reporter.record("JumpSurah");
                }
                
                shortcuts: [
                    Shortcut {
                        key: qsTr("J") + Retranslate.onLanguageChanged
                        
                        onTriggered: {
                            reporter.record("JumpShortcut");
                        }
                    }
                ]
                
                function onFinished(message)
                {
                    var surahId = parseInt( message.split("/")[0] );
                    currentPage = pageNumbers[surahId];
                    
                    reporter.record("JumpSurahResult", surahId);
                }
                
                function onDataLoaded(id, data)
                {
                    var n = data.length;
                    
                    if (id == QueryId.FetchPageNumbers && n > 0)
                    {
                        var surahs = new Array(114);
                        var i = 0;
                        
                        for (i = 0; i < n; i++)
                        {
                            var surahId = data[i].surah_id;
                            var page = data[i].page_number;
                            surahs[surahId] = page;
                        }
                        
                        var lastPage = 0;
                        
                        for (i = 0; i < 114; i++)
                        {
                            if (surahs[i] != undefined) {
                                lastPage = surahs[i];
                            } else {
                                surahs[i] = lastPage;
                            }
                        }

                        pageNumbers = surahs;
                    }
                }
                
                onCreationCompleted: {
                    app.childCardFinished.connect(onFinished);
                    helper.fetchPageNumbers(jumpSurah);
                }
            },
            
            ActionItem
            {
                id: stretchAction
                imageSource: mushaf.stretchMushaf ? "images/menu/ic_aspect_fill.png" : "images/menu/ic_stretch.png"
                title: mushaf.stretchMushaf ? qsTr("Aspect Fill") + Retranslate.onLanguageChanged : qsTr("Stretch") + Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: StretchTriggered");
                    mushaf.stretchMushaf = !mushaf.stretchMushaf;
                    
                    reporter.record("StretchMushaf", mushaf.stretchMushaf.toString());
                }
            },
            
            ActionItem
            {
                id: jumpPage
                imageSource: "images/dropdown/jump_to_page.png"
                title: qsTr("Page") + Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.OnBar
                
                function onFinished(result)
                {
                    var pageNumber = parseInt(result);
                    
                    if (pageNumber >= 1 && pageNumber <= 604) {
                        currentPage = pageNumber;
                    }
                    
                    reporter.record("JumpToPageNumber", pageNumber.toString());
                }
                
                onTriggered: {
                    console.log("UserEvent: JumpToPage");
                    persist.showPrompt( jumpPage, qsTr("Enter page number"), qsTr("Please enter the page in the mushaf you want to jump to:"), "", qsTr("Enter value between 1 and 604 inclusive"), 3, false, qsTr("Jump"), qsTr("Cancel"), SystemUiInputMode.NumericKeypad );
                    
                    reporter.record("JumpToPage");
                }
            },
            
            ActionItem
            {
                id: downloadAll
                title: qsTr("Download All") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_download_mushaf.png"
                enabled: mushaf.enableDownloadAll
                
                onTriggered: {
                    console.log("UserEvent: MushafDownloadAll");
                    mushaf.fetchMushafSize();
                    
                    reporter.record("MushafDownloadAll");
                }
            }
        ]
        
        titleBar: TitleBar
        {
            id: hiddenTitle
            visibility: ChromeVisibility.Hidden
            kind: TitleBarKind.Segmented
            
            onSelectedValueChanged: {
                if (mushaf.mushafStyle != selectedValue)
                {
                    mushaf.mushafStyle = selectedValue;
                    currentPageChanged();
                    
                    reporter.record("MushafStyleSet", selectedValue);
                }
            }
            
            onCreationCompleted: {
                var n = optionCount();
                var style = mushaf.mushafStyle;
                
                for (var i = 0; i < n; i++)
                {
                    if ( style && style == optionAt(i).value ) {
                        optionAt(i).selected = true;
                        break;
                    }
                }
            }
            
            options: [
                Option {
                    imageSource: "images/dropdown/style_tijweed.png"
                    text: qsTr("Tajweed") + Retranslate.onLanguageChanged
                    value: "style1"
                    selected: true
                },
                
                Option {
                    imageSource: "images/dropdown/mushaf_page_title.png"
                    text: qsTr("Page %1").arg(currentPage) + Retranslate.onLanguageChanged
                    enabled: false
                },
                
                Option {
                    imageSource: "images/dropdown/style_normal.png"
                    text: qsTr("No Tajweed") + Retranslate.onLanguageChanged
                    value: "style2"
                }
            ]
            
            attachedObjects: [
                Timer {
                    id: timer
                    repeat: false
                    interval: 3000
                    
                    onTriggered: {
                        hiddenTitle.visibility = ChromeVisibility.Hidden
                        mainPage.actionBarVisibility = ChromeVisibility.Hidden
                    }
                }
            ]
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container
            {
                id: rootContainer
                layout: DockLayout {}
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                ControlDelegate
                {
                    id: stretchView
                    delegateActive: mushaf.stretchMushaf
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    onDelegateActiveChanged: {
                        if (!delegateActive && control) {
                            control.cleanUp();
                        }
                    }
                    
                    sourceComponent: ComponentDefinition
                    {
                        ImageView
                        {
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            loadEffect: ImageViewLoadEffect.FadeZoom
                            imageSource: currentImageSource
                            
                            onTouch: {
                                activate();
                                
                                if ( event.isDown() ) {
                                    opacity = 0.7;
                                } else if ( event.isUp() || event.isCancel() ) {
                                    opacity = 1;
                                }
                            }
                            
                            function cleanUp() {
                                mushaf.mushafPageReady.disconnect(onPageReady);
                            }
                            
                            function onPageReady(imageData) {
                                currentImageSource = imageData.localUri;
                            }
                            
                            onCreationCompleted: {
                                mushaf.mushafPageReady.connect(onPageReady);
                            }
                        }
                    }
                }
                
                ControlDelegate
                {
                    id: nonStretchView
                    delegateActive: !mushaf.stretchMushaf
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    
                    onDelegateActiveChanged: {
                        if (!delegateActive && control) {
                            control.cleanUp();
                        }
                    }
                    
                    sourceComponent: ComponentDefinition
                    {
                        ScrollView
                        {
                            id: scrollView
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            scrollViewProperties.pinchToZoomEnabled: true
                            scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.OnPinch
                            scrollViewProperties.scrollMode: ScrollMode.Both
                            scrollRole: ScrollRole.Main
                            
                            function cleanUp() {
                                mushaf.mushafPageReady.disconnect(nonStretchImage.onPageReady);
                            }
                            
                            ImageView
                            {
                                id: nonStretchImage
                                scalingMethod: ScalingMethod.AspectFill
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                loadEffect: ImageViewLoadEffect.FadeZoom
                                imageSource: currentImageSource
                                
                                onTouch: {
                                    activate();
                                    
                                    if ( event.isDown() ) {
                                        opacity = 0.7;
                                    } else if ( event.isUp() || event.isCancel() ) {
                                        opacity = 1;
                                    }
                                }
                                
                                function onPageReady(imageData) {
                                    currentImageSource = imageData.localUri;
                                }
                                
                                onCreationCompleted: {
                                    mushaf.mushafPageReady.connect(onPageReady);
                                }
                            }
                        }
                    }
                }
                
                NavigationButton
                {
                    id: nextPage
                    defaultImageSource: "images/title/ic_prev.png"
                    disabledImageSource: "images/title/ic_prev_disabled.png"
                    verticalAlignment: VerticalAlignment.Center
                    enabled: currentPage < 604
                    
                    onClicked: {
                        console.log("UserEvent: NextPage");
                        ++currentPage;
                    }
                }
                
                NavigationButton
                {
                    id: prevPage
                    multiplier: -1
                    defaultImageSource: "images/title/ic_next.png"
                    disabledImageSource: "images/title/ic_next_disabled.png"
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Center
                    enabled: currentPage > 1
                    
                    onClicked: {
                        console.log("UserEvent: PrevPage");
                        --currentPage;
                    }
                    
                    onAnimationFinished: {
                        tutorial.exec( "mushafPrevPage", qsTr("To go to the previous page, tap here."), HorizontalAlignment.Right, VerticalAlignment.Center );
                        tutorial.exec( "mushafNextPage", qsTr("To go to the next page, tap here."), HorizontalAlignment.Left, VerticalAlignment.Center );
                        
                        if (!mushaf.stretchMushaf) {
                            tutorial.execCentered("mushafZoom", qsTr("Do a pinch gesture anywhere on the image to enlarge it or make it smaller! Or scroll right-to-left or vice-versa to pan the image."), "images/tutorial/pinch.png");
                        }
                        
                        tutorial.execCentered( "mushafTapPage", qsTr("To display the current page number, simply tap anywhere on the page and the title bar will come up."), HorizontalAlignment.Left, VerticalAlignment.Center );
                        tutorial.exec( "mushafTajweed", qsTr("Use this mode to display the version of the Mushaf that has the pronunciation rules on it."), HorizontalAlignment.Left, VerticalAlignment.Top, ui.du(2), 0, ui.du(4) );
                        tutorial.exec( "mushafNoTajweed", qsTr("Use this mode to display the version of the Mushaf that does not have pronunciation rules written on it."), HorizontalAlignment.Right, VerticalAlignment.Top, 0, ui.du(2), ui.du(4) );
                        tutorial.exec( "mushafPageNumber", qsTr("This displays the current page number you are on."), HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, ui.du(4) );
                    }
                    
                    function onFinished(key)
                    {
                        if (key == "mushafTapPage")
                        {
                            hiddenTitle.visibility = ChromeVisibility.Overlay;
                            mainPage.actionBarVisibility = ChromeVisibility.Overlay;
                        }
                    }
                    
                    onCreationCompleted: {
                        tutorial.tutorialFinished.connect(onFinished);
                    }
                }
            }
        }
    }
    
    onClosed: {
        app.childCardFinished.disconnect(jumpSurah.onFinished);
        tutorial.tutorialFinished.disconnect(onFinished);
        Application.aboutToQuit.disconnect(onAboutToQuit);       
        destroy();
    }
    
    onOpened: {
        mushaf.requestPage(currentPage);
        tutorial.execActionBar( "mushafBack", qsTr("To exit the mushaf mode, simply tap on the Back button at the bottom.") );
        tutorial.execActionBar( "mushafMenu", qsTr("Tap in the bottom-right to open the menu."), "x" );
    }
}