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

    function checkAdminStatus()
    {
        app.lazyInitComplete.disconnect(checkAdminStatus);
        reporter.adminEnabledChanged.disconnect(checkAdminStatus);
        
        if (reporter.isAdmin)
        {
            add(quotesTab);
            add(tafsirTab);
            
            //activeTab = tafsirTab;
        } else {
            reporter.adminEnabledChanged.connect(checkAdminStatus);
        }
    }
    
    onCreationCompleted: {
        app.lazyInitComplete.connect(checkAdminStatus);
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
        }
    ]
}