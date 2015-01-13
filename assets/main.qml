import bb.cascades 1.2

TabbedPane
{
    id: root
    activeTab: quranTab
    
    Menu.definition: CanadaIncMenu
    {
        id: menuDef
        allowDonations: true
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
        description: qsTr("Favourites") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_bookmarks.png"
        title: qsTr("Bookmarks") + Retranslate.onLanguageChanged
        unreadContentCount: helper.totalBookmarks

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
    
    onCreationCompleted: {
        if ( !persist.contains("firstTime") ) {
            menuDef.settings.triggered();
            persist.saveValueFor("firstTime", 1, false);
        }
    }
}