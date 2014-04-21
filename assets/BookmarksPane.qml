import bb.cascades 1.0

NavigationPane
{
    id: navigationPane

    onPopTransitionEnded: {
        page.destroy();
    }

    Page
    {
        id: mainPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        titleBar: QuranTitleBar {}

        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            topPadding: 20;
            background: back.imagePaint

            EmptyDelegate
            {
                id: noElements
                graphic: "images/placeholders/ic_empty_bookmarks.png"
                labelText: qsTr("You have no favourites. To mark a favourite, press-and-hold on an ayat or tafsir and choose 'Mark Favourite' from the context-menu.") + Retranslate.onLanguageChanged
            }

            ControlDelegate {
                id: listDelegate
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill

                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }

                sourceComponent: ComponentDefinition
                {
                    ListView
                    {
                        id: listView
                        dataModel: ArrayDataModel {}

                        function itemType(data, indexPath) {
                            return data.type;
                        }
                        
                        function deleteBookmark(indexPath)
                        {
                            var bookmarks = persist.getValueFor("bookmarks");

                            if (bookmarks && bookmarks.length > 0)
                            {
                                bookmarks.splice(indexPath, 1);

                                persist.saveValueFor("bookmarks", bookmarks);
                                persist.showToast(qsTr("Removed bookmark!"));
                            }
                        }

                        listItemComponents: [
                            ListItemComponent
                            {
                                type: "verse"

                                StandardListItem
                                {
                                    id: sli
                                    title: ListItemData.surah_name
                                    status: ListItemData.verse_id
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
                            }
                        ]

                        onTriggered: {
                            var data = dataModel.data(indexPath);

							definition.source = "SurahPage.qml";
							var sp = definition.createObject();
                            navigationPane.push(sp);
                            sp.surahId = data.surah_id;
                            sp.requestedVerse = data.verse_id;
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
        
        attachedObjects: [
            ImagePaintDefinition {
                id: back
                imageSource: "images/background.png"
            }
        ]
    }
}