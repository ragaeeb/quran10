import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    property alias searchText: searchField.text
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: TitleBar
    {
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties
        {
            Container
            {
                topPadding: 10; rightPadding: 10; leftPadding: 10
                background: back.imagePaint
                
                TextField
                {
                    id: searchField
                    hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    inputRoute.primaryKeyTarget: true;
                    bottomMargin: 0; topMargin: 0
                    
                    onTextChanged: {
                        input.submitted(undefined);
                    }
                    
                    input {
                        submitKey: SubmitKey.Submit
                        
                        onSubmitted: {
                            var trimmedText = text.replace(/^\s+|\s+$/g, "");
                            
                            if (trimmedText.length > 1)
                            {
                                theDataModel.clear()
                                listView.translationLoaded = listView.arabicLoaded = false;
                                
                                busy.running = true;
                                helper.searchQuery(listView, trimmedText);
                            }
                        }
                    }
                }
            }
        }
    }
    
    Container
    {
        background: back.imagePaint
        
        ActivityIndicator {
            id: busy
            running: false
            visible: running
            preferredHeight: 250
            horizontalAlignment: HorizontalAlignment.Center
        }
        
        EmptyDelegate
        {
            id: noElements
            graphic: "images/placeholders/empty_search.png"
            labelText: qsTr("There were no matches for your search. Please try another query.") + Retranslate.onLanguageChanged
        }
        
        ListView
        {
            id: listView
            property alias background: bg
            property bool translationLoaded: false
            property bool arabicLoaded: false
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: bg
                    imageSource: "images/header_bg.png"
                },
                
                ComponentDefinition {
                    id: definition
                    source: "SurahPage.qml"
                }
            ]
            
            function onDataLoaded(id, data)
            {
                theDataModel.insertList(data);
                
                var translation = persist.getValueFor("translation");
                
                if (id == QueryId.SearchQueryTranslation) {
                    translationLoaded = true
                } else if (id == QueryId.SearchQueryPrimary) {
                    arabicLoaded = true
                }
                
                if ( (translationLoaded && arabicLoaded) || (translation == "" && arabicLoaded) ) {
                    busy.running = false
                }
                
                noElements.delegateActive = theDataModel.isEmpty();
                listView.visible = !theDataModel.isEmpty();
            }
            
            dataModel: GroupDataModel
            {
                id: theDataModel
                sortingKeys: [ "name", "verse_id" ]
                grouping: ItemGrouping.ByFullValue
            }
            
            onTriggered: {
                if (indexPath.length > 1) {
                    var data = dataModel.data(indexPath)
                    
                    var surahPage = definition.createObject()
                    surahPage.surahId = data.surah_id
                    surahPage.requestedVerse = data.verse_id
                    
                    navigationPane.push(surahPage)
                }
            }
            
            listItemComponents: [
                
                ListItemComponent
                {
                    type: "header"
                    
                    Container {
                        id: headerRoot
                        horizontalAlignment: HorizontalAlignment.Fill
                        topPadding: 5
                        bottomPadding: 5
                        leftPadding: 5
                        background: ListItem.view.background.imagePaint
                        
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        
                        Label {
                            text: ListItemData
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.fontSize: FontSize.XXSmall
                            textStyle.color: Color.White
                            textStyle.fontWeight: FontWeight.Bold
                            textStyle.textAlign: TextAlign.Center
                            
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                        }
                    }
                },
                
                ListItemComponent
                {
                    type: "item"
                    
                    Container {
                        id: itemRoot
                        leftPadding: 5
                        rightPadding: 5
                        bottomPadding: 5
                        horizontalAlignment: HorizontalAlignment.Fill
                        preferredWidth: 1280
                        
                        Divider {
                            visible: itemRoot.ListItem.indexPath[1] != 0
                            bottomMargin: 0
                        }
                        
                        Label {
                            text: ListItemData.text
                            multiline: true
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.color: Color.White
                            textStyle.textAlign: TextAlign.Center
                            topMargin: 0
                        }
                    }
                }
            ]
        }
        
        attachedObjects: [
            ImagePaintDefinition {
                id: back
                imageSource: "images/background.png"
            }
        ]
    }
}