import bb.cascades 1.3

TabbedPane
{
    id: root
    activeTab: quranTab
    
    onActiveTabChanged: {
        peekEnabled = activeTab != ummahTab;
    }
    
    Menu.definition: CanadaIncMenu
    {
        id: menuDef
        allowDonations: true
        bbWorldID: "27022877"
        help.imageSource: "images/menu/ic_help.png"
        help.title: qsTr("Help") + Retranslate.onLanguageChanged
        projectName: "quran10"
        settings.imageSource: "images/menu/ic_settings.png"
        settings.title: qsTr("Settings") + Retranslate.onLanguageChanged
    }

	Tab
	{
        id: quranTab
        title: qsTr("Qu'ran") + Retranslate.onLanguageChanged
        description: qsTr("القرآن") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_quran_open.png"
        unreadContentCount: 114
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
	    
        onTriggered: {
            console.log("UserEvent: QuranTab");
        }
	    
        delegate: Delegate {
            source: "QuranPane.qml"
        }
	}

    Tab {
        id: bookmarks
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        description: qsTr("Saved Verses") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_bookmarks.png"
        title: qsTr("Favourites") + Retranslate.onLanguageChanged

        onTriggered: {
            console.log("UserEvent: FavouritesTab");
        }

        delegate: Delegate {
            source: "BookmarksPane.qml"
        }
    }

    Tab {
        id: search
        title: qsTr("Search") + Retranslate.onLanguageChanged
        description: qsTr("Find") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_search.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected

        onTriggered: {
            console.log("UserEvent: SearchTab");
        }

        delegate: Delegate {
            source: "SearchPane.qml"
        }
    }
    
    Tab {
        id: radio
        title: qsTr("Radio") + Retranslate.onLanguageChanged
        description: qsTr("Live") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_radio.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        onTriggered: {
            console.log("UserEvent: RadioTab");
        }
        
        delegate: Delegate {
            source: "RadioPane.qml"
        }
    }
    
    Tab {
        id: supplications
        title: qsTr("Supplications") + Retranslate.onLanguageChanged
        description: qsTr("Du'a from the Qu'ran") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_supplications.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
        
        onTriggered: {
            console.log("UserEvent: SupplicationsTab");
        }
        
        delegate: Delegate {
            source: "SupplicationsPane.qml"
        }
    }
    
    Tab {
        title: qsTr("Transfers") + Retranslate.onLanguageChanged
        description: qsTr("Download Manager") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_transfers.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
        unreadContentCount: queue.queued
        
        onTriggered: {
            console.log("UserEvent: TransfersTab");
            transfers.active = true;
        }
    }
    
    Tab {
        id: ummahTab
        title: qsTr("The Ummah") + Retranslate.onLanguageChanged
        description: qsTr("The Muslim Ummah") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_ummah.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
        
        onTriggered: {
            console.log("UserEvent: UmmahTab");
        }
        
        delegate: Delegate {
            source: "LocationPane.qml"
        }
    }

    function checkAdminStatus()
    {
        app.lazyInitComplete.disconnect(checkAdminStatus);
        reporter.adminEnabledChanged.disconnect(checkAdminStatus);
        
        if (reporter.isAdmin)
        {
            add(quotesTab);
            add(tafsirTab);
            add(rijaalTab);
            
            //activeTab = tafsirTab;
        } else {
            reporter.adminEnabledChanged.connect(checkAdminStatus);
        }
        
        tutorial.exec("openTabMenu", qsTr("Tap here to open the menu"), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(2), 0, 0, ui.du(1)/2);
        tutorial.exec("openAppMenu", qsTr("Swipe down from the top-bezel to display the Settings and Help and file bugs!"), HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, 0, ui.du(2), "images/menu/ic_bottom.png", "d");
        tutorial.exec("swipeOpenTabMenu", qsTr("Swipe right to open the menu!"), HorizontalAlignment.Left, VerticalAlignment.Center, 0, 0, 0, 0, undefined, "r");
    }
    
    function onSidebarVisualStateChanged(newState)
    {
        sidebarStateChanged.disconnect(onSidebarVisualStateChanged);

        tutorial.exec("tabsIntro", qsTr("Here you will find the different sections of the app available to you.\n\nThere the Favourites tab: Any verses you mark as favourite will end up here.\There is the Search tab. You can use this to quickly find a specific verse via keywords.\There is the Radio tab. You can use this to listen to online Qu'ran radio streams.\In the Supplications tab you will find a collection of some of the many du'aa that are found across the Qu'ran.\n\nIn the Transfers tab. This is a list of all the downloads that the app has done this session.\n\nIn the Ummah tab, you can browse the various callers, students of knowledge, and scholars of the past and present."), HorizontalAlignment.Left, VerticalAlignment.Top, ui.du(1), 0, ui.du(10), 0, undefined, "d" );
    }
    
    onCreationCompleted: {
        app.lazyInitComplete.connect(checkAdminStatus);
        sidebarStateChanged.connect(onSidebarVisualStateChanged);
    }
    
    attachedObjects: [
        Tab
        {
            id: quotesTab
            title: qsTr("Quotes") + Retranslate.onLanguageChanged
            description: qsTr("Sayings of the Salaf") + Retranslate.onLanguageChanged
            imageSource: "images/tabs/ic_quotes.png"
            delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
            newContentAvailable: admin.pendingUpdates
            
            onTriggered: {
                console.log("UserEvent: Quotes");
            }
            
            delegate: Delegate {
                source: "QuotesPane.qml"
            }
        },
        
        Tab
        {
            id: tafsirTab
            title: qsTr("Tafsir") + Retranslate.onLanguageChanged
            description: qsTr("Explanations") + Retranslate.onLanguageChanged
            imageSource: "images/tabs/ic_tafsir.png"
            delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
            newContentAvailable: admin.pendingUpdates
            
            onTriggered: {
                console.log("UserEvent: TafsirTab");
            }
            
            delegate: Delegate {
                source: "TafsirPane.qml"
            }
        },
        
        Tab
        {
            id: rijaalTab
            title: qsTr("Rijaal") + Retranslate.onLanguageChanged
            description: qsTr("Individuals") + Retranslate.onLanguageChanged
            imageSource: "images/list/ic_companion.png"
            delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
            newContentAvailable: admin.pendingUpdates
            
            onTriggered: {
                console.log("UserEvent: RijaalTab");
            }
            
            delegate: Delegate {
                source: "IndividualsPane.qml"
            }
        }
    ]
}