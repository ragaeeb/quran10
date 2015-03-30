import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: tafsirContentsPage
    property variant suiteId
    property alias title: tb.title
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onSuiteIdChanged: {
        busy.delegateActive = true;
        helper.fetchAllTafsirForSuite(listView, suiteId);
        
        var marker = persist.getValueFor("suitePageMarker");
        
        if ( marker && (marker.suiteId == suiteId) ) {
            tafsirContentsPage.addAction(jumpToMarker);
        } else {
            tafsirContentsPage.removeAction(jumpToMarker);
        }
    }
    
    titleBar: TitleBar {
        id: tb
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(tafsirContentsPage, listView, true);
    }
    
    actions: [
        ActionItem
        {
            id: addAction
            imageSource: "images/menu/ic_add_suite_page.png"
            title: qsTr("Add") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: TafsirContentAddTriggered");
                var sheetControl = contentDef.createObject();
                sheetControl.open();
            }
            
            attachedObjects: [
                ComponentDefinition
                {
                    id: contentDef
                    
                    Sheet
                    {
                        id: sheet
                        property variant suitePageId
                        property string currentText
                        property string headingText
                        property variant indexPath
                        
                        onOpened: {
                            bodyField.requestFocus();
                        }
                        
                        onClosed: {
                            destroy();
                        }
                        
                        Page
                        {
                            titleBar: TitleBar
                            {
                                title: !sheet.suitePageId ? qsTr("New Page") + Retranslate.onLanguageChanged : qsTr("Edit Page") + Retranslate.onLanguageChanged
                                
                                dismissAction: ActionItem {
                                    imageSource: "images/dropdown/suite_changes_cancel.png"
                                    title: qsTr("Cancel") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: NewTafsirCancelTriggered");
                                        sheet.close();
                                    }
                                }
                                
                                acceptAction: ActionItem
                                {
                                    id: saveAction
                                    imageSource: "images/dropdown/suite_changes_accept.png"
                                    title: qsTr("Save") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: NewTafsirPageSaveTriggered");

                                        var newText = bodyField.text.trim();
                                        var headingValue = heading.text.trim();
                                        
                                        if (!sheet.suitePageId) {
                                            tafsirHelper.addTafsirPage(listView, suiteId, newText, headingValue);
                                        } else {
                                            tafsirHelper.editTafsirPage(listView, sheet.suitePageId, newText, headingValue);
                                            var item = adm.data(sheet.indexPath);
                                            item["body"] = newText;
                                            item["heading"] = headingValue;
                                            adm.replace(sheet.indexPath[0], item);
                                        }

                                        sheet.close();
                                    }
                                }
                            }
                            
                            Container
                            {
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                
                                TextField {
                                    id: heading
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    hintText: qsTr("Heading...") + Retranslate.onLanguageChanged
                                    text: sheet.headingText
                                    backgroundVisible: false
                                    input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                                    
                                    gestureHandlers: [
                                        DoubleTapHandler {
                                            onDoubleTapped: {
                                                console.log("UserEvent: TafsirHeadingDoubleTapped");
                                                heading.text = textUtils.toTitleCase( persist.getClipboardText() );
                                            }
                                        }
                                    ]
                                }
                                
                                TextArea
                                {
                                    id: bodyField
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    verticalAlignment: VerticalAlignment.Fill
                                    backgroundVisible: false
                                    content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                                    text: sheet.currentText
                                    hintText: qsTr("Enter tafsir body here...") + Retranslate.onLanguageChanged
                                    input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                                    topPadding: 0; topMargin: 0
                                    
                                    onTextChanging: {
                                        saveAction.enabled = text.trim().length > 10;
                                    }
                                    
                                    gestureHandlers: [
                                        DoubleTapHandler {
                                            onDoubleTapped: {
                                                console.log("UserEvent: TafsirBodyDoubleTapped");
                                                bodyField.text = textUtils.optimize( persist.getClipboardText() );
                                            }
                                        }
                                    ]
                                    
                                    layoutProperties: StackLayoutProperties {
                                        spaceQuota: 1
                                    }
                                }
                            }
                        }
                    }
                }
            ]
        }
    ]
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        ListView
        {
            id: listView
            scrollRole: ScrollRole.Main
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            function onDataLoaded(id, data)
            {
                if (id == QueryId.FetchAllTafsirForSuite)
                {
                    if ( adm.isEmpty() ) {
                        adm.append(data);
                    } else {
                        adm.insert(0, data[0]); // add the latest value to avoid refreshing entire list
                        listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                    }
                    
                    if ( adm.isEmpty() ) {
                        addAction.triggered();
                    }
                } else if (id == QueryId.AddTafsirPage) {
                    persist.showToast( qsTr("Tafsir page added!"), "", "asset:///images/menu/ic_add_suite_page.png" );
                    suiteIdChanged();
                } else if (id == QueryId.RemoveTafsirPage) {
                    persist.showToast( qsTr("Tafsir page removed!"), "", "asset:///images/menu/ic_delete_suite_page.png" );
                } else if (id == QueryId.EditTafsirPage) {
                    persist.showToast( qsTr("Tafsir page updated!"), "", "asset:///images/menu/ic_edit_suite_page.png" );
                }
                
                busy.delegateActive = false;
                listView.visible = !adm.isEmpty();
                noElements.delegateActive = !listView.visible;
            }
            
            function removeItem(ListItemData) {
                tafsirHelper.removeTafsirPage(listView, ListItemData.id);
                busy.delegateActive = true;
            }
            
            function editItem(indexPath, ListItemData)
            {
                var sheetControl = contentDef.createObject();
                sheetControl.suitePageId = ListItemData.id;
                sheetControl.currentText = ListItemData.body;
                sheetControl.headingText = ListItemData.heading;
                sheetControl.indexPath = indexPath;
                sheetControl.open();
            }
            
            function setSuitePageMarker(ListItem)
            {
                persist.saveValueFor("suitePageMarker", {'suiteId': suiteId, 'indexPath': ListItem.indexPath[0]});
                persist.showToast( qsTr("Market set"), "", "asset:///images/menu/ic_set_marker.png" );
            }
            
            onTriggered: {
                console.log("UserEvent: TafsirContentTriggered");
                definition.source = "TafsirAyats.qml";
                var page = definition.createObject();
                page.suitePageId = dataModel.data(indexPath).id;
                
                navigationPane.push(page);
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    Container
                    {
                        id: rootItem
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        
                        Header {
                            id: header
                            title: ListItemData.heading && ListItemData.heading.length > 0 ? ListItemData.heading : ListItemData.id
                        }
                        
                        Label
                        {
                            content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            multiline: true
                            text: ListItemData.body
                        }
                        
                        contextActions: [
                            ActionSet
                            {
                                title: header.title
                                subtitle: ListItemData.body
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_copy.png"
                                    title: qsTr("Copy") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: CopyTafsirContentTriggered");
                                        persist.copyToClipboard(ListItemData.body);
                                    }
                                }
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_edit_suite_page.png"
                                    title: qsTr("Edit") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: EditTafsirContentTriggered");
                                        rootItem.ListItem.view.editItem(rootItem.ListItem.indexPath, ListItemData);
                                    }
                                }
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_set_marker.png"
                                    title: qsTr("Set Marker") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: SetSuitePageMarker");
                                        rootItem.ListItem.view.setSuitePageMarker(rootItem.ListItem);
                                    }
                                }
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_delete_suite_page.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: RemoveTafsirPageTriggered");
                                        rootItem.ListItem.view.removeItem(ListItemData);
                                        rootItem.ListItem.view.dataModel.removeAt(rootItem.ListItem.indexPath[0]);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
        }
        
        EmptyDelegate
        {
            id: noElements
            graphic: "images/placeholders/empty_suite_pages.png"
            labelText: qsTr("No elements found. Tap on the Add button to add a new one.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                addAction.triggered();
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_suite_pages.png"
        }
    }
    
    attachedObjects: [
        ActionItem
        {
            id: jumpToMarker
            imageSource: "images/menu/ic_set_marker.png"
            title: qsTr("Jump to Marker") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: JumpToMarker");
                var marker = persist.getValueFor("suitePageMarker");
                listView.scrollToItem([marker.indexPath], ScrollAnimation.None)
            }
        }
    ]
}