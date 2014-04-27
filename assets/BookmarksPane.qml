import bb.cascades 1.0
import bb.system 1.0

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
        
        actions: [
            DeleteActionItem
            {
                enabled: listDelegate.delegateActive
                imageSource: "images/menu/ic_bookmark_delete.png"
                title: qsTr("Clear Bookmarks") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    prompt.show();
                }
            }
        ]

        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            background: back.imagePaint

            EmptyDelegate
            {
                id: noElements
                graphic: "images/placeholders/ic_empty_bookmarks.png"
                labelText: qsTr("You have no favourites. To mark a favourite, press-and-hold on an ayat or tafsir and choose 'Mark Favourite' from the context-menu.") + Retranslate.onLanguageChanged
            }

            ControlDelegate
            {
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
                                persist.showToast( qsTr("Removed bookmark!"), "", "asset:///images/menu/ic_bookmark_delete.png" );
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
                                    status: "%1:%2".arg(ListItemData.surah_id).arg(ListItemData.verse_id)
                                    description: ListItemData.text
                                    imageSource: "images/ic_quran.png"

                                    contextActions: [
                                        ActionSet
                                        {
                                            title: sli.title
                                            subtitle: sli.description

                                            DeleteActionItem
                                            {
                                                imageSource: "images/menu/ic_bookmark_delete.png"
                                                title: qsTr("Remove") + Retranslate.onLanguageChanged

                                                onTriggered: {
                                                    itemDeletedAnim.play();
                                                }
                                            }
                                        }
                                    ]
                                    
                                    animations: [
                                        ScaleTransition
                                        {
                                            id: itemDeletedAnim
                                            fromX: 1
                                            toX: 0
                                            duration: 500
                                            easingCurve: StockCurve.CubicOut

                                            onEnded: {
                                                sli.ListItem.view.deleteBookmark(sli.ListItem.indexPath);
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
            ImagePaintDefinition
            {
                id: back
                imageSource: "images/backgrounds/background.png"
            },
            
            SystemDialog
            {
                id: prompt
                title: qsTr("Confirmation") + Retranslate.onLanguageChanged
                body: qsTr("Are you sure you want to clear all bookmarks?") + Retranslate.onLanguageChanged
                confirmButton.label: qsTr("Yes") + Retranslate.onLanguageChanged
                cancelButton.label: qsTr("No") + Retranslate.onLanguageChanged
                
                onFinished: {
                    if (result == SystemUiResult.ConfirmButtonSelection) {
                        persist.remove("bookmarks");
                    }
                }
            }
        ]
    }
}