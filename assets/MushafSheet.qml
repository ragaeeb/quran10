import QtQuick 1.0
import bb.cascades 1.2
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
        
        tutorial.expandOverflow("mushaf");
        tutorial.execActionBar( "mushafBack", qsTr("To exit the mushaf mode, simply tap on the Back button at the bottom.") );
        tutorial.exec( "mushafPrevPage", qsTr("To go to the previous page, tap here."), HorizontalAlignment.Right, VerticalAlignment.Center );
        tutorial.exec( "mushafNextPage", qsTr("To go to the next page, tap here."), HorizontalAlignment.Left, VerticalAlignment.Center );
        
        if (!mushaf.stretchMushaf) {
            tutorial.execCentered("mushafZoom", qsTr("Do a pinch gesture anywhere on the image to enlarge it or make it smaller! Or scroll right-to-left or vice-versa to pan the image."), "images/common/pinch.png");
        }
        
        tutorial.execTitle( "mushafTajweed", qsTr("Use this mode to display the version of the Mushaf that has the pronunciation rules on it."), "l" );
        tutorial.execTitle( "mushafNoTajweed", qsTr("Use this mode to display the version of the Mushaf that does not have pronunciation rules written on it."), "r" );
        tutorial.execTitle( "mushafPageNumber", qsTr("This displays the current page number you are on.") );
    }
    
    Page
    {
        id: mainPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        actionBarVisibility: ChromeVisibility.Hidden
        
        onActionMenuVisualStateChanged: {
            if (actionMenuVisualState == ActionMenuVisualState.VisibleFull)
            {
                tutorial.execOverFlow( "mushafJumpSurah", qsTr("Use the '%1' action to select a specific surah in the mushaf you want to jump to."), jumpSurah );
                tutorial.execOverFlow( "mushafJumpPage", qsTr("Use the '%1' action to jump to a specific page number in the mushaf."), jumpPage );
                tutorial.execOverFlow( "mushafDownloadAll", qsTr("Quran10 does its best to minimize your data usage by lazily downloading the pages as you need them. However, if you want to download them all at once tap on the '%1' action."), downloadAll );
                tutorial.execActionBar( "mushafPlay", qsTr("To play this page in the recitation, tap here."), "l" );

                if (mushaf.stretchMushaf) {
                    tutorial.execOverFlow( "mushafAspectFill", qsTr("Use the '%1' action to resize the mushaf according to its original dimensions. In this mode you will have to do pinch-and-zoom and pan gestures with your fingers in order to view the different parts of the page."), stretchAction );
                } else {
                    tutorial.execOverFlow( "mushafStretch", qsTr("Use the '%1' action to stretch the mushaf page to fill your screen size. Note that this may not always be visually attractive."), stretchAction );
                }
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
                id: backButton
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
                id: playAllAction
                property int playingPage
                title: player.playing && (playingPage == currentPage) ? qsTr("Pause") : qsTr("Play")
                imageSource: player.playing && (playingPage == currentPage) ? "images/menu/ic_pause.png" : "images/menu/ic_play.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered:
                {
                    console.log("UserEvent: PlayAll");
                    
                    timer.restart();

                    if ( player.active && (playingPage == currentPage) ) {
                        player.togglePlayback();
                        reporter.record("TogglePlay");
                    } else {
                        recitation.downloadAndPlay(currentPage, 0);
                        reporter.record("PlayPage", currentPage.toString());
                    }
                }
            },
            
            ActionItem
            {
                id: stretchAction
                imageSource: mushaf.stretchMushaf ? "images/menu/ic_aspect_fill.png" : "images/menu/ic_stretch.png"
                title: mushaf.stretchMushaf ? qsTr("Aspect Fill") + Retranslate.onLanguageChanged : qsTr("Stretch") + Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.InOverflow
                
                onTriggered: {
                    console.log("UserEvent: StretchTriggered");
                    mushaf.stretchMushaf = !mushaf.stretchMushaf;
                    
                    reporter.record("StretchMushaf", mushaf.stretchMushaf.toString());
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
                id: bookmark
                imageSource: "images/menu/ic_mark_favourite.png"
                title: qsTr("Bookmark") + Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.OnBar
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.CreateNew
                    }
                ]
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.SaveBookmark)
                    {
                        persist.showToast( qsTr("Favourite added for Page %1").arg(currentPage), "images/menu/ic_bookmark_add.png" );
                        bookmarkHelper.bookmarksUpdated();
                    }
                }
                
                function onTagEntered(tag, name)
                {
                    bookmarkHelper.saveBookmark(bookmark, currentPage, 0, name, tag);
                    reporter.record("BookmarkPage", currentPage);
                    reporter.record("FavouriteTag", tag);
                }
                
                function onFinished(name)
                {
                    if (name.length > 0) {
                        persist.showPrompt( bookmark, qsTr("Enter tag"), qsTr("You can use this to categorize related pages together."), "", qsTr("Enter a tag for this bookmark (ie: ramadan). You can leave this blank if you don't want to use a tag."), 50, "onTagEntered", name );
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: BookmarkPageTriggered");
                    persist.showPrompt( bookmark, qsTr("Enter name"), qsTr("You can use this to quickly recognize this page in the favourites tab."), qsTr("Page #%1").arg(currentPage), qsTr("Name..."), 50 );
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
                
                function onFinished(confirmed)
                {
                    if (confirmed) {
                        mushaf.requestEntireMushaf();
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: MushafDownloadAll");
                    persist.showConfirmDialog( downloadAll, qsTr("This setting may require a download of the images of the pages. Would you like to download the images now? If you select no, they will be downloaded as you access each page manually.") );
                    
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
                
                SeekBar {
                    horizontalAlignment: HorizontalAlignment.Center
                    preferredWidth: deviceUtils.pixelSize.width-tutorial.du(15)
                    visible: mainPage.actionBarVisibility == ChromeVisibility.Overlay && player.active
                    
                    onTouch: {
                        if ( event.isDown() ) {
                            timer.stop();
                        } else if ( event.isUp() || event.isCancel() ) {
                            timer.restart();
                        }
                    }
                    
                    onVisibleChanged: {
                        if (visible) {
                            tutorial.execSwipe("mushafSeek", qsTr("Swipe right and left to seek the recitation!"), HorizontalAlignment.Left, VerticalAlignment.Center, "r");
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
                    visible: mainPage.actionBarVisibility == ChromeVisibility.Overlay
                    
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
                    visible: mainPage.actionBarVisibility == ChromeVisibility.Overlay
                    
                    onClicked: {
                        console.log("UserEvent: PrevPage");
                        --currentPage;
                    }
                    
                    onAnimationFinished: {
                        tutorial.execCentered( "mushafTapPage", qsTr("To display the current page number, simply tap anywhere on the page and the title bar will come up."), HorizontalAlignment.Left, VerticalAlignment.Center );
                    }
                    
                    function onStarted(key) {
                        timer.stop();
                    }
                    
                    function onFinished(key)
                    {
                        if (key == "mushafTapPage")
                        {
                            hiddenTitle.visibility = ChromeVisibility.Overlay;
                            mainPage.actionBarVisibility = ChromeVisibility.Overlay;
                        }
                        
                        activate();
                    }
                    
                    onCreationCompleted: {
                        tutorial.tutorialFinished.connect(onFinished);
                        tutorial.tutorialStarted.connect(onStarted);
                    }
                }
            }
        }
    }
    
    onClosed: {
        player.stop();
        
        recitation.readyToPlay.disconnect(onReady);
        player.metaDataChanged.disconnect(onMetaDataChanged);
        app.childCardFinished.disconnect(jumpSurah.onFinished);
        tutorial.tutorialStarted.disconnect(prevPage.onStarted);
        tutorial.tutorialFinished.disconnect(prevPage.onFinished);
        Application.aboutToQuit.disconnect(backButton.onAboutToQuit);       
        destroy();
    }
    
    function onReady(uri) {
        player.play(uri);
    }
    
    function onMetaDataChanged(metaData) {
        playAllAction.playingPage = recitation.extractPage(metaData);
    }
    
    onOpened: {
        mushaf.requestPage(currentPage);
        recitation.readyToPlay.connect(onReady);
        player.metaDataChanged.connect(onMetaDataChanged);
    }
    
    attachedObjects: [
        LazyMediaPlayer
        {
            id: player
            
            onError: {
                console.log(message);
                persist.showToast( message, "asset:///images/toast/yellow_delete.png" );
                
                reporter.record("PagePlayError", message);
            }
        }
    ]
}