import bb.cascades 1.0

TabbedPane {
    id: root
    activeTab: quranTab

    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]

    Menu.definition: MenuDefinition {
        settingsAction: SettingsActionItem {
            property Page settingsPage

            onTriggered: {
                if (! settingsPage) {
                    definition.source = "SettingsPage.qml"
                    settingsPage = definition.createObject()
                }

                root.activePane.push(settingsPage);
            }
            
            onCreationCompleted: {
                if ( persist.getValueFor("tutorialCount") != 1 ) {
                    persist.saveValueFor("tutorialCount", 1);
                    triggered();
                }
            }
        }
        
        actions: [
            ActionItem {
                title: qsTr("Bug Reports") + Retranslate.onLanguageChanged
                imageSource: "images/ic_bugs.png"
                
                onTriggered: {
                    bugReports.trigger("bb.action.OPEN");
                }
                
                attachedObjects: [
                    Invocation {
                        id: bugReports
                        
                        query: InvokeQuery {
                            mimeType: "text/html"
                            uri: "http://code.google.com/p/quran10/issues/list"
                            invokeActionId: "bb.action.OPEN"
                        }
                    }
                ]
            }
        ]

        helpAction: HelpActionItem {
            property Page helpPage

            onTriggered: {
                if (! helpPage) {
                    definition.source = "HelpPage.qml"
                    helpPage = definition.createObject();
                }

                root.activePane.push(helpPage);
            }
        }
    }

    QuranTab {
        id: quranTab
        title: qsTr("Qu'ran") + Retranslate.onLanguageChanged
        description: qsTr("القرآن") + Retranslate.onLanguageChanged
        imageSource: "images/ic_quran_open.png"
        unreadContentCount: mushafQueue.queued + queue.queued
        newContentAvailable: unreadContentCount > 0
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

    function lazyLoad(actualSource, tab) {
        definition.source = actualSource;

        var actual = definition.createObject();
        tab.content = actual;

        return actual;
    }
}