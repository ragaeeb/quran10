import bb.cascades 1.2
import com.canadainc.data 1.0

Page
{
    id: mainPage
    signal picked(int chapter, int verse)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll

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
        }
    }
    
    onPeekedAtChanged: {
        listView.secretPeek = peekedAt;
    }
    
    Container
    {
        background: back.imagePaint
        
        TextField
        {
            id: textField
            hintText: qsTr("Search surah name or number (ie: '2' for Surah Al-Baqara)...") + Retranslate.onLanguageChanged
            bottomMargin: 0
            horizontalAlignment: HorizontalAlignment.Fill
            inputRoute.primaryKeyTarget: true;
            
            onTextChanging: {
                helper.fetchChapters(listView, text);
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
            
            dataModel: ArrayDataModel {
                id: theDataModel
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        id: sli
                        property bool peek: ListItem.view.secretPeek
                        title: ListItemData.transliteration ? ListItemData.transliteration : ListItemData.name
                        description: ListItemData.transliteration ? ListItemData.name : qsTr("%n ayahs", "", ListItemData.verse_count)
                        status: ListItemData.surah_id
                        imageSource: "images/ic_quran.png"

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
                    theDataModel.append(data);
                }
            }
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