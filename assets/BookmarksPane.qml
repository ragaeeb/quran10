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
        
        actions: [
            DeleteActionItem
            {
                enabled: listView.visible
                imageSource: "images/menu/ic_bookmark_delete.png"
                title: qsTr("Clear Bookmarks") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: ClearBookmarks");
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

            ListView
            {
                id: listView
                dataModel: ArrayDataModel {
                    id: adm
                }
                
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
                            scaleX: 1
                            
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
                                            console.log("UserEvent: RemoveBookmark");
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
                                        sli.scaleX = 1;
                                    }
                                }
                            ]
                        }
                    }
                ]
                
                onTriggered: {
                    console.log("UserEvent: Bookmark Triggered");
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

            onCreationCompleted: {
                persist.settingChanged.connect(reloadNeeded);
                reloadNeeded("bookmarks");
            }

            function reloadNeeded(key)
            {
                if (key == "bookmarks")
                {
                    var bookmarks = persist.getValueFor("bookmarks");

                    if (!bookmarks) {
                        bookmarks = [];
                    }

                    adm.clear();
                    adm.append(bookmarks);

                    noElements.delegateActive = adm.isEmpty();
                    listView.visible = !noElements.delegateActive;

                    if (listView.visible) {
                        persist.tutorial( "tutorialBookmarkDel", qsTr("To delete an existing bookmark, simply press-and-hold on it and choose 'Remove' from the menu."), "asset:///images/menu/ic_bookmark_delete.png" );
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