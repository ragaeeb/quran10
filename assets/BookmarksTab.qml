import bb.cascades 1.0

NavigationPane
{
    id: navigationPane

    onPopTransitionEnded: {
        page.destroy();
    }

    BasePage {
        id: mainPage

        actions: [
            InvokeActionItem {
                title: qsTr("Donate") + Retranslate.onLanguageChanged
                imageSource: "images/ic_donate.png"
                ActionBar.placement: ActionBarPlacement.OnBar

                query {
                    mimeType: "text/html"
                    uri: "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=dar.as.sahaba@hotmail.com&currency_code=CAD&no_shipping=1&tax=0&lc=CA&bn=PP-DonationsBF&item_name=Da'wah Activities, Rent and Utility Expenses for the Musalla (please do not use credit cards)"
                    invokeActionId: "bb.action.OPEN"
                }
            }
        ]

        contentContainer: Container
        {
            topPadding: 20

            Divider {
                topMargin: 0
                bottomMargin: 0
            }

            ControlDelegate {
                id: noElements
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill

                sourceComponent: ComponentDefinition {
                    Label {
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        textStyle.textAlign: TextAlign.Center
                        multiline: true
                        text: qsTr("You have no favourites. To mark a favourite, press-and-hold on a hadith and choose 'Mark Favourite' from the context-menu.") + Retranslate.onLanguageChanged
                    }
                }
            }

            ControlDelegate {
                id: listDelegate
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill

                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }

                sourceComponent: ComponentDefinition {
                    ListView {
                        id: listView
                        dataModel: ArrayDataModel {}

                        function itemType(data, indexPath) {
                            return data.table;
                        }
                        
                        function deleteBookmark(indexPath)
                        {
                            var bookmarks = persist.getValueFor("bookmarks");

                            if (! bookmarks) {
                                bookmarks = [];
                            }

                            bookmarks.splice(indexPath, 1);
                            
                            persist.saveValueFor("bookmarks", bookmarks);
                            persist.showToast( qsTr("Removed bookmark!") );
                        }

                        listItemComponents: [
                            ListItemComponent {
                                type: "verse"

                                StandardListItem {
                                    id: sli
                                    title: ListItemData.surah_name
                                    status: ListItemData.verse
                                    description: ListItemData.text
                                    imageSource: "images/ic_quran.png"

                                    contextActions: [
                                        ActionSet {
                                            title: sli.title
                                            subtitle: sli.description

                                            DeleteActionItem {
                                                title: qsTr("Remove") + Retranslate.onLanguageChanged

                                                onTriggered: {
                                                    sli.ListItem.view.deleteBookmark(sli.ListItem.indexPath);
                                                }
                                            }
                                        }
                                    ]
                                }
                            },

                            ListItemComponent {
                                type: "tafsir"
                            }
                        ]

                        onTriggered: {
                            var data = dataModel.data(indexPath);

							definition.source = "SurahPage.qml";
							var sp = definition.createObject();
                            navigationPane.push(sp);
                            sp.surahId = data.surah;
                            sp.requestedVerse = data.verse
                        }

                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill

                        attachedObjects: [
                            ComponentDefinition {
                                id: definition
                            }
                        ]
                    }
                }
            }

            onCreationCompleted: {
                persist.settingChanged.connect(reloadNeeded);
                reloadNeeded("bookmarks");
            }

            function reloadNeeded(key)
            {
                if (key == "bookmarks")
                {
                    var bookmarks = persist.getValueFor("bookmarks");

                    if (bookmarks && bookmarks.length > 0) {
                        noElements.delegateActive = false;
                        listDelegate.delegateActive = true;

                        listDelegate.control.dataModel.clear();
                        listDelegate.control.dataModel.append(bookmarks);
                    } else {
                        noElements.delegateActive = true;
                        listDelegate.delegateActive = false;
                    }
                }
            }
        }
    }
}