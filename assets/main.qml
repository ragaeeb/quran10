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

    function checkAdminStatus()
    {
        tutorial.exec("openTabMenu", qsTr("Tap here to open the menu"), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(2), 0, 0, ui.du(1)/2);
        tutorial.exec("openAppMenu", qsTr("Swipe down from the top-bezel to display the Settings and Help and file bugs!"), HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, 0, ui.du(2), "images/menu/ic_bottom.png", "d");
        tutorial.exec("swipeOpenTabMenu", qsTr("Swipe right to expand the menu!"), HorizontalAlignment.Left, VerticalAlignment.Center, 0, 0, 0, 0, undefined, "r");
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
    
    onCreationCompleted: {
        app.lazyInitComplete.connect(checkAdminStatus);
        sidebarStateChanged.connect(onSidebarVisualStateChanged);
    }
}