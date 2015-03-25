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
    
    Page
    {
        id: mainPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        actionBarVisibility: ChromeVisibility.Hidden
        
        actions: [
            ActionItem
            {
                title: qsTr("Jump") + Retranslate.onLanguageChanged
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                imageSource: "images/menu/ic_jump.png"
                
                onTriggered: {
                    console.log("UserEvent: JumpMushaf");
                    hiddenTitle.visibility = ChromeVisibility.Hidden;
                    dropDownDelegate.visible = dropDownDelegate.delegateActive = true;
                    timer.stop();
                }
                
                shortcuts: [
                    Shortcut {
                        key: qsTr("J") + Retranslate.onLanguageChanged
                    }
                ]
            },
            
            ActionItem
            {
                title: qsTr("Download All") + Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "images/menu/ic_download_mushaf.png"
                property variant totalSize: 0
                
                function onDeflated(success, error) {
                    enabled = true;
                }
                
                function onMushafSizeFetched(cookie, total)
                {
                    if (cookie == "mushafSize")
                    {
                        totalSize = total;
                        
                        var freeSpace = app.getFreeSpace();
                        var confirmed = persist.showBlockingDialog( qsTr("Confirmation"), qsTr("The total size of the mushaf is ~%1 and it will need to be downloaded. Your device currently has ~%2 free space remaining. Make sure you are on a good Wi-Fi connection or have a good data plan. Do you wish to continue?").arg( textUtils.bytesToSize(total) ).arg( textUtils.bytesToSize(freeSpace) ), qsTr("Yes"), qsTr("No"), freeSpace > total );
                        
                        if (confirmed) {
                            console.log("UserEvent: DownoloadMushafPromptYes");
                            mushaf.requestEntireMushaf();
                            mushaf.deflationDone.connect(onDeflated);
                        } else {
                            console.log("UserEvent: DownoloadMushafPromptNo");
                            enabled = true;
                        }
                    }
                }
                
                onCreationCompleted: {
                    queue.sizeFetched.connect(onMushafSizeFetched);
                }
                
                onTriggered: {
                    console.log("UserEvent: MushafDownloadAll");
                    enabled = false;
                    
                    if (totalSize > 0) {
                        onMushafSizeFetched(totalSize);
                    } else {
                        mushaf.fetchMushafSize();
                    }
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
            }
        ]
        
        titleBar: TitleBar
        {
            id: hiddenTitle
            visibility: ChromeVisibility.Hidden
            title: qsTr("Page %1").arg(currentPage) + Retranslate.onLanguageChanged
            
            dismissAction: ActionItem
            {
                imageSource: "images/ic_quran.png"
                title: qsTr("Back") + Retranslate.onLanguageChanged
                
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
            }
            
            attachedObjects: [
                Timer {
                    id: timer
                    repeat: false
                    interval: 2000
                    
                    onTriggered: {
                        hiddenTitle.visibility = ChromeVisibility.Hidden
                        mainPage.actionBarVisibility = ChromeVisibility.Hidden
                        dropDownDelegate.visible = false;
                    }
                }
            ]
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            ControlDelegate
            {
                id: dropDownDelegate
                horizontalAlignment: HorizontalAlignment.Fill
                delegateActive: false
                visible: false
                
                sourceComponent: ComponentDefinition
                {
                    DropDown
                    {
                        id: dropDown
                        horizontalAlignment: HorizontalAlignment.Fill
                        title: qsTr("Surah") + Retranslate.onLanguageChanged
                        
                        onSelectedValueChanged: {
                            if (selectedValue == -1) {
                                var pageNumber = parseInt( persist.showBlockingPrompt( qsTr("Enter page number"), qsTr("Please enter the page in the mushaf you want to jump to:"), "", qsTr("Enter value between 1 and 604 inclusive"), 3, false, qsTr("Jump"), qsTr("Cancel"), SystemUiInputMode.NumericKeypad ) );
                                
                                if (pageNumber >= 1 && pageNumber <= 604) {
                                    currentPage = pageNumber;
                                }
                            } else {
                                currentPage = selectedValue;
                            }
                        }
                        
                        function onDataLoaded(id, data)
                        {
                            var n = data.length;
                            
                            if (id == QueryId.FetchPageNumbers && n > 0)
                            {
                                var option = optionDefinition.createObject();
                                option.text = qsTr("Jump to Page");
                                option.description = qsTr("Jump to a specific page number");
                                option.value = -1;
                                dropDownDelegate.control.add(option);
                                
                                for (var i = 0; i < n; i++)
                                {
                                    var current = data[i];
                                    
                                    option = optionDefinition.createObject();
                                    option.text = current.name;
                                    option.description = current.transliteration ? current.transliteration : qsTr("%n verses", "", current.verse_count);
                                    option.value = current.page_number;
                                    dropDownDelegate.control.add(option);
                                }
                                
                                dropDownDelegate.control.expanded = true;
                            }
                        }
                        
                        onCreationCompleted: {
                            helper.fetchPageNumbers(dropDown);
                        }
                    }
                }
                
                attachedObjects: [
                    ComponentDefinition
                    {
                        id: optionDefinition

                        Option {
                            imageSource: "images/dropdown/ic_surah.png"
                        }
                    }
                ]
            }
            
            SegmentedControl
            {
                horizontalAlignment: HorizontalAlignment.Fill
                visible: dropDownDelegate.visible
                
                Option {
                    text: qsTr("With Tijweed") + Retranslate.onLanguageChanged
                    value: "style1"
                }
                
                Option {
                    text: qsTr("Without Tijweed") + Retranslate.onLanguageChanged
                    value: "style2"
                }
                
                onSelectedValueChanged: {
                    var changed = persist.saveValueFor("mushafStyle", selectedValue, false);
                    
                    if (changed) {
                        currentPageChanged();
                    }
                }
                
                onCreationCompleted: {
                    var n = count();
                    var style = persist.getValueFor("mushafStyle");
                    
                    for (var i = 0; i < n; i++)
                    {
                        if ( style == at(i).value ) {
                            at(i).selected = true;
                            break;
                        }
                    }
                }
            }
            
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
                                hiddenTitle.visibility = ChromeVisibility.Overlay;
                                mainPage.actionBarVisibility = ChromeVisibility.Overlay;
                                timer.restart();
                                
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
                                    hiddenTitle.visibility = ChromeVisibility.Overlay;
                                    mainPage.actionBarVisibility = ChromeVisibility.Overlay;
                                    timer.restart();
                                    
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