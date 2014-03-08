import bb.cascades 1.2

TabbedPane
{
    id: root
    activeTab: quranTab
    
    Menu.definition: CanadaIncMenu
    {
        projectName: "quran10"
        allowDonations: true
        promoteChannel: true
        bbWorldID: "27022877"
    }

	Tab
	{
        id: quranTab
        title: qsTr("Qu'ran") + Retranslate.onLanguageChanged
        description: qsTr("القرآن") + Retranslate.onLanguageChanged
        imageSource: "images/ic_quran_open.png"
        unreadContentCount: mushafQueue.queued + queue.queued
        newContentAvailable: unreadContentCount > 0
	    
	    QuranPane {}
	}

    Tab {
        id: bookmarks
        title: qsTr("Bookmarks") + Retranslate.onLanguageChanged
        description: qsTr("Favourites") + Retranslate.onLanguageChanged
        imageSource: "images/ic_bookmarks.png"
        
        function onSettingsChanged(key)
        {
            if (key == "bookmarks")
            {
                var bookmarks = persist.getValueFor("bookmarks");
                
                if (bookmarks && bookmarks.length > 0) {
                    unreadContentCount = bookmarks.length;
                }
            }
        }
        
        onCreationCompleted: {
            persist.settingChanged.connect(onSettingsChanged);
            onSettingsChanged("bookmarks");
        }

        onTriggered: {
            if (! content) {
                lazyLoad("BookmarksTab.qml", bookmarks);
            }
        }
    }

    Tab {
        id: search
        title: qsTr("Search") + Retranslate.onLanguageChanged
        description: qsTr("Find") + Retranslate.onLanguageChanged
        imageSource: "images/ic_search.png"

        onTriggered: {
            if (! content) {
                lazyLoad("SearchPage.qml", search);
            }
        }
    }
    
    Tab {
        id: radio
        title: qsTr("Radio") + Retranslate.onLanguageChanged
        description: qsTr("Live") + Retranslate.onLanguageChanged
        imageSource: "images/ic_radio.png"
        
        onTriggered: {
            if (! content) {
                lazyLoad("RadioTab.qml", radio);
            }
        }
    }
    
    Tab {
        id: supplications
        title: qsTr("Supplications") + Retranslate.onLanguageChanged
        description: qsTr("Du'a from the Qu'ran") + Retranslate.onLanguageChanged
        imageSource: "images/ic_supplications.png"
        
        onTriggered: {
            if (! content) {
                lazyLoad("SupplicationsTab.qml", supplications);
            }
        }
    }

    function lazyLoad(actualSource, tab) {
        definition.source = actualSource;

        var actual = definition.createObject();
        tab.content = actual;

        return actual;
    }
}