import bb.cascades 1.0
import bb.cascades.pickers 1.0
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
        
        onActionMenuVisualStateChanged: {
            if (actionMenuVisualState == ActionMenuVisualState.VisibleFull) {
                tutorial.execActionBar( "clearBookmarks", qsTr("Tap on the '%1' action to clear all the bookmarks.").arg(clearBookmarks.title), "x" );
            }
        }
        
        actions: [
            ActionItem
            {
                id: backup
                title: qsTr("Backup") + Retranslate.onLanguageChanged
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                imageSource: "images/menu/ic_backup.png"
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.CreateNew
                    }
                ]
                
                onTriggered: {
                    console.log("UserEvent: Backup");
                    filePicker.title = qsTr("Select Destination");
                    filePicker.mode = FilePickerMode.Saver
                    filePicker.defaultSaveFileNames = ["quran_bookmarks.zip"]
                    filePicker.allowOverwrite = true;
                    
                    filePicker.open();
                }
                
                function onSaved(result) {
                    persist.showToast( qsTr("Successfully backed up to %1").arg(result), "images/menu/ic_backup.png" );
                }
                
                onCreationCompleted: {
                    offloader.backupComplete.connect(onSaved);
                }
            },
            
            ActionItem
            {
                id: restore
                title: qsTr("Restore") + Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "images/menu/ic_restore.png"
                
                onTriggered: {
                    console.log("UserEvent: Restore");
                    filePicker.title = qsTr("Select File");
                    filePicker.mode = FilePickerMode.Picker
                    
                    filePicker.open();
                }
                
                function onRestored(result)
                {
                    if (result) {
                        persist.showBlockingDialog( qsTr("Successfully Restored"), qsTr("The app will now close itself so when you re-open it the restored bookmarks can take effect!"), qsTr("OK"), "" );
                        Application.requestExit();
                    } else {
                        persist.init( qsTr("The database could not be restored. Please re-check the backup file to ensure it is valid, and if the problem persists please file a bug report. Make sure to attach the backup file with your report!"), "images/menu/ic_restore_error.png" );
                    }
                }
                
                onCreationCompleted: {
                    offloader.restoreComplete.connect(onRestored);
                }
            },
            
            DeleteActionItem
            {
                id: clearBookmarks
                enabled: listView.visible
                imageSource: "images/menu/ic_clear_bookmarks.png"
                title: qsTr("Clear Bookmarks") + Retranslate.onLanguageChanged
                
                function onFinished(confirmed)
                {
                    if (confirmed) {
                        console.log("UserEvent: ClearFavouritesPromptYes");
                        bookmarkHelper.clearAllBookmarks(listView);
                    } else {
                        console.log("UserEvent: ClearFavouritesPromptNo");
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: ClearFavourites");
                    persist.showDialog( clearBookmarks, qsTr("Confirmation"), qsTr("Are you sure you want to clear all bookmarks?") );
                }
            }
        ]
        
        titleBar: TitleBar {
            title: qsTr("Favourites") + Retranslate.onLanguageChanged
            scrollBehavior: TitleBarScrollBehavior.NonSticky
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            background: global.mainBackground.imagePaint
            layout: DockLayout {}
            
            EmptyDelegate
            {
                id: noElements
                graphic: "images/placeholders/empty_bookmarks.png"
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
                scrollRole: ScrollRole.Main
                
                dataModel: GroupDataModel
                {
                    id: gdm
                    grouping: ItemGrouping.ByFullValue
                    sortingKeys: ["tag"]
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllBookmarks) {
                        busy.delegateActive = false;
                        
                        gdm.clear();
                        gdm.insertList(data);
                        
                        refresh();
                        
                        if ( listView.visible && tutorial.isTopPane(navigationPane, mainPage) )
                        {
                            tutorial.execCentered( "bookmarkDel", qsTr("To delete an existing bookmark, simply press-and-hold on it and choose 'Remove' from the menu.") );
                            tutorial.execActionBar( "backup", qsTr("Tap on the '%1' action to backup these bookmarks so you can restore them later if you ever switch devices.").arg(backup.title) );
                            tutorial.execActionBar( "restore", qsTr("Tap on the '%1' action to restore bookmarks that you have backed up before.").arg(restore.title), "r" );
                        }
                    } else if (id == QueryId.ClearAllBookmarks) {
                        persist.showToast( qsTr("Cleared all bookmarks!"), "images/menu/ic_favourite_remove.png" );
                        gdm.clear();
                        refresh();
                    } else if (id == QueryId.RemoveBookmark) {
                        persist.showToast( qsTr("Removed bookmark!"), "images/menu/ic_favourite_remove.png" );
                    }
                }
                
                function refresh()
                {
                    noElements.delegateActive = gdm.isEmpty();
                    listView.visible = !noElements.delegateActive;
                    
                    navigationPane.parent.unreadContentCount = gdm.size();
                }
                
                function deleteBookmark(indexPath) {
                    bookmarkHelper.removeBookmark( listView, dataModel.data(indexPath).id );
                    gdm.removeAt(indexPath);
                    refresh();
                }
                
                function onBookmarksUpdated() {
                    bookmarkHelper.fetchAllBookmarks(listView);
                }
                
                onCreationCompleted: {
                    busy.delegateActive = true;
                    onBookmarksUpdated();
                    global.bookmarksUpdated.connect(onBookmarksUpdated);
                }
                
                listItemComponents: [
                    ListItemComponent {
                        type: "header"
                        
                        Header {
                            title: ListItemData.length > 0 ? ListItemData : qsTr("Uncategorized") + Retranslate.onLanguageChanged
                            subtitle: ListItem.view.dataModel.childCount(ListItem.indexPath)
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "item"
                        
                        StandardListItem
                        {
                            id: sli
                            title: ListItemData.name
                            status: ListItemData.verse_id
                            description: ListItemData.surah_name
                            imageSource: "images/list/ic_bookmark.png"
                            
                            contextActions: [
                                ActionSet
                                {
                                    title: sli.title
                                    subtitle: sli.description
                                    
                                    DeleteActionItem
                                    {
                                        imageSource: "images/menu/ic_favourite_remove.png"
                                        
                                        onTriggered: {
                                            console.log("UserEvent: RemoveFavourite");
                                            sli.ListItem.view.deleteBookmark(sli.ListItem.indexPath);
                                        }
                                    }
                                }
                            ]
                        }
                    }
                ]
                
                onTriggered: {
                    console.log("UserEvent: FavouriteTriggered");
                    var data = dataModel.data(indexPath);
                    
                    var sp = global.createObject("AyatPage.qml");
                    navigationPane.push(sp);
                    sp.surahId = data.surah_id;
                    sp.verseId = data.verse_id;
                }
                
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
            }
        }
    }
    
    attachedObjects: [
        FilePicker {
            id: filePicker
            defaultType: FileType.Other
            filter: ["*.zip"]
            
            directories :  {
                return ["/accounts/1000/removable/sdcard", "/accounts/1000/shared/misc"]
            }
            
            onFileSelected : {
                console.log("UserEvent: FileSelected", selectedFiles[0]);
                
                if (mode == FilePickerMode.Picker) {
                    offloader.restore(selectedFiles[0]);
                } else {
                    offloader.backup(selectedFiles[0]);
                }
            }
        }
    ]
}