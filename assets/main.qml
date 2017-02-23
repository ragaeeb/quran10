import bb.cascades 1.2

TabbedPane
{
    id: root
    activeTab: quranTab
    
    function onSidebarVisualStateChanged()
    {
        sidebarStateChanged.disconnect(onSidebarVisualStateChanged);
        
        tutorial.execTabbedPane("favs", qsTr("In the %1 tab: Any verses you mark as favourite will end up here."), favs );
        tutorial.execTabbedPane("search", qsTr("In the %1 tab you can use this to quickly find a specific verse via keywords."), search );
        tutorial.execTabbedPane("duaa", qsTr("In the %1 tab you will find a collection of some of the many du'aa that are found across the Qu'ran."), supplications );
        
        reporter.record( "TabbedPaneExpanded", root.sidebarVisualState.toString() );
    }
    
    onActivePaneChanged: {
        Qt.navigationPane = activePane;
    }
    
    Menu.definition: CanadaIncMenu
    {
        id: menuDef
        allowDonations: true
        bbWorldID: "27022877"
        projectName: "quran10"
        helpPageQml: "QuranHelp.qml"
        
        onFinished: {
            sidebarStateChanged.connect(onSidebarVisualStateChanged);
            
            tutorial.execAppMenu();
            tutorial.exec("openTabMenu", qsTr("Tap here to open the menu"), HorizontalAlignment.Left, VerticalAlignment.Bottom, tutorial.du(2), 0, 0, tutorial.du(1)/2);
            tutorial.execSwipe("swipeOpenTabMenu", qsTr("Swipe right to expand the menu!"), HorizontalAlignment.Left, VerticalAlignment.Center, "r");
            
            if ( reporter.deferredCheck("checkedSalat10", 10) ) {
                persist.findTarget("headless:", "com.canadainc.SalatTenService", root);
            }

            quranTab.delegate.object.onLazyInitComplete();
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
        id: articles
        title: qsTr("Articles") + Retranslate.onLanguageChanged
        description: qsTr("Benefits") + Retranslate.onLanguageChanged
        imageSource: "images/list/ic_tafsir.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        onTriggered: {
            console.log("UserEvent: ArticlesTab");
            reporter.record("ArticlesTab");
        }
        
        delegate: Delegate {
            source: "ArticlesPane.qml"
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
}