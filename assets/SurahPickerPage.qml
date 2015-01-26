import bb.cascades 1.2
import com.canadainc.data 1.0

Page
{
    id: mainPage
    signal picked(int chapter, int verse)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property alias pickerList: listView

    titleBar: TitleBar
    {
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties
        {
            Container
            {
                id: titleBar
                background: titleBack.imagePaint
                rightPadding: 50
                layout: DockLayout {}
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Top
                
                ImageView
                {
                    imageSource: "images/title/logo.png"
                    topMargin: 0
                    leftMargin: 0
                    rightMargin: 0
                    bottomMargin: 0
                    loadEffect: ImageViewLoadEffect.FadeZoom
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Center
                    
                    animations: [
                        FadeTransition {
                            id: fadeInLogo
                            easingCurve: StockCurve.CubicIn
                            fromOpacity: 0
                            toOpacity: 1
                            duration: 1000
                        }
                    ]
                }
                
                attachedObjects: [
                    ImagePaintDefinition {
                        id: titleBack
                        imageSource: "images/title/title_bg.png"
                    }
                ]
            }
            
            expandableArea
            {
                expanded: sortOrder.selectedOption == null
                
                content: Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    DropDown
                    {
                        id: sortOrder
                        title: qsTr("Display Options") + Retranslate.onLanguageChanged
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        Option {
                            id: alphabet
                            text: qsTr("Alphabetical Order") + Retranslate.onLanguageChanged
                            description: qsTr("Sorted by surah name") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/sort_alphabet.png"
                            value: "name"
                        }
                        
                        Option {
                            id: oldest
                            text: qsTr("Normal") + Retranslate.onLanguageChanged
                            description: qsTr("The surahs will be displayed in the standard order") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/sort_normal.png"
                            value: ""
                        }
                        
                        Option {
                            id: recent
                            text: qsTr("Revelation Order") + Retranslate.onLanguageChanged
                            description: qsTr("Display chapters int he order they were revealed") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/sort_revelation.png"
                            value: "revelation_order"
                        }
                        
                        onSelectedValueChanged: {
                            textField.textChanging(textField.text);
                        }
                    }
                }
            }
        }
    }
    
    onPeekedAtChanged: {
        listView.secretPeek = peekedAt;
    }
    
    Container
    {
        background: back.imagePaint
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            TextField
            {
                id: textField
                hintText: qsTr("Search surah name or number (ie: '2' for Surah Al-Baqara)...") + Retranslate.onLanguageChanged
                bottomMargin: 0
                horizontalAlignment: HorizontalAlignment.Fill
                inputRoute.primaryKeyTarget: true;
                
                onTextChanging: {
                    var ok = helper.fetchChapters(listView, text, sortOrder.selectedValue);
                    busy.delegateActive = ok;
                }
                
                input {
                    submitKey: SubmitKey.Submit
                    
                    onSubmitted: {
                        if ( text.match(/^\d{1,3}:\d{1,3}$/) || text.match(/^\d{1,3}$/) )
                        {
                            var tokens = text.split(":");
                            var surah = parseInt(tokens[0]);
                            
                            if (tokens.length > 0) {
                                var verse = parseInt(tokens[1]);
                                picked(surah, verse);
                            } else {
                                picked(surah, 0);
                            }
                        }
                    }
                }
                
                animations: [
                    TranslateTransition {
                        id: translate
                        fromX: 1000
                        duration: 500
                        
                        onEnded: {
                            textField.requestFocus();
                        }
                    }
                ]
            }
            
            ListView
            {
                id: listView
                objectName: "listView"
                property bool secretPeek: false
                
                dataModel: GroupDataModel {
                    id: theDataModel
                    sortingKeys: ["juz_id", "surah_id"]
                }
                
                listItemComponents: [
                    ListItemComponent {
                        type: "header"
                        
                        Header {
                            title: qsTr("Juz %1").arg(ListItemData)
                            subtitle: ListItem.view.dataModel.childCount(ListItem.indexPath)
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "item"
                        
                        StandardListItem
                        {
                            id: sli
                            property bool peek: ListItem.view.secretPeek
                            title: ListItemData.transliteration ? ListItemData.transliteration : ListItemData.name
                            description: ListItemData.transliteration ? ListItemData.name : qsTr("%n ayahs", "", ListItemData.verse_count)
                            status: ListItemData.verse_number ? ListItemData.verse_number : ListItemData.surah_id
                            imageSource: "images/ic_quran.png"
                            contextActions: ActionSet {}
                            
                            onPeekChanged: {
                                if (peek) {
                                    showAnim.play();
                                }
                            }
                            
                            opacity: 0
                            animations: [
                                FadeTransition
                                {
                                    id: showAnim
                                    fromOpacity: 0
                                    toOpacity: 1
                                    duration: Math.min( sli.ListItem.indexInSection*300, 750 );
                                }
                            ]
                            
                            ListItem.onInitializedChanged: {
                                if (initialized) {
                                    showAnim.play();
                                }
                            }
                        }
                    }
                ]
                
                onTriggered: {
                    console.log("UserEvent: SurahTriggered");
                    var data = listView.dataModel.data(indexPath);
                    picked(data.surah_id, 0);
                }
                
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchChapters)
                    {
                        theDataModel.clear();
                        
                        var n = data.length;
                        var lastJuzId;
                        
                        for (var i = 0; i < n; i++)
                        {
                            var current = data[i];
                            
                            if (current.juz_id) {
                                lastJuzId = current.juz_id;
                            } else {
                                current["juz_id"] = lastJuzId;
                                data[i] = current;
                            }
                        }
                        
                        theDataModel.insertList(data);
                        busy.delegateActive = false;
                        noElements.delegateActive = theDataModel.isEmpty();
                        listView.visible = !noElements.delegateActive;
                    }
                }
            }
        }
        
        EmptyDelegate
        {
            id: noElements
            graphic: "images/placeholders/empty_chapters.png"
            labelText: qsTr("No chapters matched your search criteria. Please try a different search term.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                console.log("UserEvent: NoChaptersTapped");
                textField.requestFocus();
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_chapters.png"
        }
    }
    
    function onReady()
    {
        textField.textChanging("");
        fadeInLogo.play();
        translate.play();

        textField.input["keyLayout"] = 7;
    }
    
    onCreationCompleted: {
        app.lazyInitComplete.connect(onReady);
    }
    
    attachedObjects: [
        ImagePaintDefinition {
            id: back
            imageSource: "images/backgrounds/background.png"
        }
    ]
}