import bb.cascades 1.0
import com.canadainc.data 1.0

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
        
        onCreationCompleted: {
            deviceUtils.attachTopBottomKeys(mainPage, listView, true);
        }
        
        actions: [
            DeleteActionItem
            {
                enabled: listView.visible
                imageSource: "images/menu/ic_clear_bookmarks.png"
                title: qsTr("Clear Bookmarks") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: ClearBookmarks");
                    var confirmed = persist.showBlockingDialog( qsTr("Confirmation"), qsTr("Are you sure you want to clear all bookmarks?") );
                    
                    if (confirmed) {
                        console.log("UserEvent: ClearBookmarksPromptYes");
                        helper.clearAllBookmarks(listView);
                    } else {
                        console.log("UserEvent: ClearBookmarksPromptNo");
                    }
                }
            }
        ]
        
        titleBar: TitleBar {
            title: qsTr("Bookmarks") + Retranslate.onLanguageChanged
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            background: back.imagePaint
            layout: DockLayout {}
            
            EmptyDelegate
            {
                id: noElements
                graphic: "images/placeholders/ic_empty_bookmarks.png"
                labelText: qsTr("You have no favourites. To mark a favourite, go to a hadith, and choose 'Mark Favourite' from the bottom action bar.") + Retranslate.onLanguageChanged
            }

            ProgressControl
            {
                id: busy
                asset: "images/progress/loading_bookmarks.png"
            }
            
            ListView
            {
                id: listView
                
                dataModel: GroupDataModel
                {
                    id: gdm
                    grouping: ItemGrouping.ByFullValue
                    sortingKeys: ["tag"]
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.SetupBookmarks) {
                        busy.delegateActive = true;
                        helper.fetchAllBookmarks(listView);
                    } else if (id == QueryId.FetchAllBookmarks) {
                        //busy.delegateActive = false;
                        
                        gdm.clear();
                        gdm.insertList(data);
                        
                        noElements.delegateActive = gdm.isEmpty();
                        listView.visible = !noElements.delegateActive;
                        
                        if (listView.visible && navigationPane.parent.parent.activePane == navigationPane && navigationPane.top == mainPage) {
                            persist.tutorial( "tutorialBookmarkDel", qsTr("To delete an existing bookmark, simply press-and-hold on it and choose 'Remove' from the menu."), "asset:///images/menu/ic_bookmark_delete.png" );
                        }
                        
                        navigationPane.parent.unreadContentCount = data.length;
                    } else if (id == QueryId.ClearAllBookmarks) {
                        persist.showToast( qsTr("Cleared all bookmarks!"), "", "asset:///images/menu/ic_bookmark_delete.png" );
                    } else if (id == QueryId.RemoveBookmark) {
                        persist.showToast( qsTr("Removed bookmark!"), "", "asset:///images/menu/ic_bookmark_delete.png" );
                    }
                }
                
                function deleteBookmark(indexPath) {
                    helper.removeBookmark( listView, dataModel.data(indexPath).id );
                }
                
                onCreationCompleted: {
                    busy.delegateActive = true;
                    helper.fetchAllBookmarks(listView);
                }
                
                listItemComponents: [
                    ListItemComponent {
                        type: "header"
                        
                        Header {
                            title: ListItemData.length > 0 ? ListItemData : qsTr("Uncategorized") + Retranslate.onLanguageChanged
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "item"
                        
                        StandardListItem
                        {
                            id: sli
                            title: ListItemData.name
                            status: ListItemData.hadithNumber
                            description: collections.renderAppropriate(ListItemData.collection)
                            imageSource: collections.render(ListItemData.collection).imageSource
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
                                            sli.ListItem.view.deleteBookmark(sli.ListItem.indexPath);
                                        }
                                    }
                                }
                            ]
                        }
                    }
                ]
                
                onTriggered: {
                    console.log("UserEvent: BookmarkTriggered");
                    var data = dataModel.data(indexPath);
                    
                    definition.source = "SurahPage.qml";
                    var sp = definition.createObject();
                    navigationPane.push(sp);
                    sp.surahId = data.surah_id;
                    sp.requestedVerse = data.verse_id;
                }
                
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
            }
        }
        
        attachedObjects: [
            ImagePaintDefinition
            {
                id: back
                imageSource: "images/backgrounds/background.png"
            },
            
            ComponentDefinition {
                id: definition
            }
        ]
    }
}