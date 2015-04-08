import QtQuick 1.0
import bb.cascades 1.0
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
        
        actions: [
            ActionItem
            {
                imageSource: "images/ic_quran.png"
                title: qsTr("Back") + Retranslate.onLanguageChanged
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: MushafBack");
                    onAboutToQuit();
                    sheet.close();
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
                }
                
                shortcuts: [
                    Shortcut {
                        key: qsTr("J") + Retranslate.onLanguageChanged
                    }
                ]
                
                function onFinished(message)
                {
                    var surahId = parseInt( message.split("/")[0] );
                    currentPage = pageNumbers[surahId-1];
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
                        dropDownDelegate.control.expanded = true;
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
                }
            },
            
            ActionItem
            {
                imageSource: "images/dropdown/jump_to_page.png"
                title: qsTr("Page") +Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: JumpToPage");
                    var pageNumber = parseInt( persist.showBlockingPrompt( qsTr("Enter page number"), qsTr("Please enter the page in the mushaf you want to jump to:"), "", qsTr("Enter value between 1 and 604 inclusive"), 3, false, qsTr("Jump"), qsTr("Cancel"), SystemUiInputMode.NumericKeypad ) ).trim();
                    
                    if (pageNumber >= 1 && pageNumber <= 604) {
                        currentPage = pageNumber;
                    }
                }
            },
            
            ActionItem
            {
                id: downloadAll
                title: qsTr("Download All") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_download_mushaf.png"
                
                function onDeflated(success, error)
                {
                    console.log("Mushaf deflated", success, error);
                    enabled = true;
                }
                
                function onFinished(confirmed, data)
                {
                    if (confirmed) {
                        console.log("UserEvent: DownoloadMushafPromptYes");
                        mushaf.requestEntireMushaf(data);
                    } else {
                        console.log("UserEvent: DownoloadMushafPromptNo");
                        enabled = true;
                    }
                }
                
                function onMushafSizeFetched(data)
                {
                    var archiveSize = data.size;
                    
                    if (archiveSize && data.uri && data.md5 && data.mushafSizeFetch)
                    {
                        var freeSpace = offloader.getFreeSpace();
                        persist.showDialog( downloadAll, data, qsTr("Confirmation"), qsTr("The total size of the mushaf is ~%1 and it will need to be downloaded. Your device currently has ~%2 free space remaining. Make sure you are on a good Wi-Fi connection or have a good data plan. Do you wish to continue?").arg( textUtils.bytesToSize(archiveSize) ).arg( textUtils.bytesToSize(freeSpace) ), qsTr("Yes"), qsTr("No"), freeSpace > archiveSize );
                    }
                }
                
                onCreationCompleted: {
                    mushaf.deflationDone.connect(onDeflated);
                    mushaf.archiveDataFetched.connect(onMushafSizeFetched);
                }
                
                onTriggered: {
                    console.log("UserEvent: MushafDownloadAll");
                    enabled = false;
                    mushaf.fetchMushafSize();
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
                }
            }
            
            onCreationCompleted: {
                var n = optionCount();
                var style = mushaf.mushafStyle;
                
                for (var i = 0; i < n; i++)
                {
                    if ( style == optionAt(i).value ) {
                        optionAt(i).selected = true;
                        break;
                    }
                }
            }
            
            options: [
                Option {
                    imageSource: "images/dropdown/style_tijweed.png"
                    text: qsTr("Tijweed") + Retranslate.onLanguageChanged
                    value: "style1"
                },
                
                Option {
                    imageSource: "images/dropdown/mushaf_page_title.png"
                    text: qsTr("Page %1").arg(currentPage) + Retranslate.onLanguageChanged
                    enabled: false
                },
                
                Option {
                    imageSource: "images/dropdown/style_normal.png"
                    text: qsTr("No Tijweed") + Retranslate.onLanguageChanged
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
                    delegateActive: mushaf.stretchMushaf
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
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
                    delegateActive: !mushaf.stretchMushaf
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    
                    sourceComponent: ComponentDefinition
                    {
                        ScrollView
                        {
                            id: scrollView
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            scrollViewProperties.pinchToZoomEnabled: true
                            scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.OnPinch
                            scrollRole: ScrollRole.Main
                            
                            ImageView
                            {
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
                }
            }
        }
    }
    
    onClosed: {
        destroy();
    }
    
    onOpened: {
        mushaf.requestPage(currentPage);
        
        persist.tutorial( "tutorialMushaf", qsTr("You can pinch on the page to zoom in and out and scroll up and down."), "asset:///images/menu/ic_mushaf.png" );
        
        if ( persist.tutorial( "tutorialNavigation", qsTr("Use the left and right arrows to switch pages."), "asset:///images/title/ic_prev.png" ) ) {}
        else if ( persist.tutorial( "tutorialJump", qsTr("Tap on the screen, then on the bottom action bar you will see the Jump icon. Use this to trigger the dropdown menu to jump to a specific surah in the mushaf."), "asset:///images/menu/ic_jump.png" ) ) {}
    }
}