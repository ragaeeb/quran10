import bb.cascades 1.3

TabbedPane
{
    id: root
    activeTab: quranTab
    
    onActiveTabChanged: {
        peekEnabled = activeTab != ummahTab;
    }
    
    function onSidebarVisualStateChanged()
    {
        sidebarStateChanged.disconnect(onSidebarVisualStateChanged);
        tutorial.tutorialFinished.connect(onTutorialFinished);
        
        tutorial.exec("tabsFavs", qsTr("In the Favourites tab: Any verses you mark as favourite will end up here."), HorizontalAlignment.Left, VerticalAlignment.Top, ui.du(1), 0, ui.du(10), 0, favs.imageSource.toString(), "d" );
        tutorial.exec("tabsSearch", qsTr("In the Search tab you can use this to quickly find a specific verse via keywords."), HorizontalAlignment.Left, VerticalAlignment.Top, ui.du(1), 0, ui.du(10), 0, search.imageSource.toString(), "d" );
        tutorial.exec("tabsDuaa", qsTr("In the Supplications tab you will find a collection of some of the many du'aa that are found across the Qu'ran."), HorizontalAlignment.Left, VerticalAlignment.Top, ui.du(1), 0, ui.du(10), 0, supplications.imageSource.toString(), "d" );
        tutorial.exec("tabsUmmah", qsTr("In the Ummah tab you can browse the various callers, students of knowledge, and scholars of the past and present."), HorizontalAlignment.Left, VerticalAlignment.Top, ui.du(1), 0, ui.du(10), 0, ummahTab.imageSource.toString(), "d" );
        
        reporter.record( "TabbedPaneExpanded", root.sidebarVisualState.toString() );
    }
    
    function onFinished(result, cookie)
    {
        if (result)
        {
            if (cookie.app == "salat10") {
                persist.openUri("http://appworld.blackberry.com/webstore/content/21198062");
            } else if (cookie.app == "sunnah10") {
                persist.openUri("http://appworld.blackberry.com/webstore/content/30105889");
            }
        }
        
        reporter.record(cookie, result);
    }
    
    function onTargetLookupFinished(target, result)
    {
        if (target == "com.canadainc.SalatTenService")
        {
            if (!result) {
                persist.showDialog(root, {'app': "salat10"}, qsTr("Salat10"), qsTr("We also have an app called 'Salat10' to help you calculate accurate prayer timings! Do you want to visit BlackBerry World to download it?"), qsTr("Yes"), qsTr("No") );
            }
            
            persist.setFlag("checkedSalat10", result);
        } else if (target == "com.canadainc.Sunnah10.shortcut") {
            if (!result) {
                persist.showDialog(root, {'app': "sunnah10"}, qsTr("Sunnah10"), qsTr("We also have an app called 'Sunnah10' to help you browse the books of hadith! Do you want to visit BlackBerry World to download it?"), qsTr("Yes"), qsTr("No") );
            }
            
            persist.setFlag("checkedSunnah10", result);
        }
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
        
        onFinished: {
            sidebarStateChanged.connect(onSidebarVisualStateChanged);
            
            tutorial.exec("openTabMenu", qsTr("Tap here to open the menu"), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(2), 0, 0, ui.du(1)/2);
            tutorial.exec("openAppMenu", qsTr("Swipe down from the top-bezel to display the Settings and Help and file bugs!"), HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, 0, ui.du(2), "images/menu/ic_bottom.png", "d");
            tutorial.exec("swipeOpenTabMenu", qsTr("Swipe right to expand the menu!"), HorizontalAlignment.Left, VerticalAlignment.Center, 0, 0, 0, 0, undefined, "r");
            
            if ( deferredCheck("checkedSalat10", 10) ) {
                persist.findTarget("headless:", "com.canadainc.SalatTenService", root);
            } else if ( deferredCheck("checkedSunnah10", 15) ) {
                persist.findTarget("sunnah://", "com.canadainc.Sunnah10.shortcut", root);
            }
        }
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
            reporter.record("QuranTab");
        }
	    
        delegate: Delegate {
            source: "QuranPane.qml"
        }
	}

    Tab {
        id: favs
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        description: qsTr("Saved Verses") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_bookmarks.png"
        title: qsTr("Favourites") + Retranslate.onLanguageChanged

        onTriggered: {
            console.log("UserEvent: FavouritesTab");
            reporter.record("FavouritesTab");
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
            reporter.record("SearchTab");
        }

        delegate: Delegate {
            source: "SearchPane.qml"
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
            reporter.record("SupplicationsTab");
        }
        
        delegate: Delegate {
            source: "SupplicationsPane.qml"
            
            onActiveChanged: {
                if (!active && object) {
                    object.cleanUp();
                }
            }
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
            reporter.record("UmmahTab");
        }
        
        delegate: Delegate {
            source: "LocationPane.qml"
        }
    }
    
    function onTutorialFinished(key)
    {
        if (key == "tabsUmmah")
        {
            if ( persist.getFlag("settingsShown") != 1 )
            {
                menuDef.settings.triggered();
                persist.setFlag("settingsShown", 1);
            }
        }
    }
}