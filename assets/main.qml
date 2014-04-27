import bb.cascades 1.2

TabbedPane
{
    id: root
    activeTab: quranTab
    
    Menu.definition: CanadaIncMenu
    {
        id: menuDef
        allowDonations: true
        bbWorldID: "27022877"
        projectName: "quran10"
        promoteChannel: true
        showSubmitLogs: true
    }

	Tab
	{
        id: quranTab
        title: qsTr("Qu'ran") + Retranslate.onLanguageChanged
        description: qsTr("القرآن") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_quran_open.png"
        unreadContentCount: 114
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
	    
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
        
        delegate: Delegate {
            source: "SupplicationsPane.qml"
        }
    }
    
    onCreationCompleted: {
        if ( !persist.contains("firstTime") ) {
            menuDef.settings.triggered();
            persist.saveValueFor("firstTime", 1);
        }
    }
}