import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    Page
    {
        id: articlesPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: TitleBar {}
        
        Container
        {
            background: tafseerBackground.imagePaint
            layout: DockLayout {}
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                background: Color.Black
                opacity: 0.4
            }
            
            EmptyDelegate
            {
                id: emptyDelegate
                graphic: "images/placeholders/empty_tafsir.png"
                labelText: qsTr("No articles found.") + Retranslate.onLanguageChanged
                
                onImageTapped: {
                    console.log("UserEvent: NoArticlesFoundTapped");
                }
            }
            
            ProgressControl
            {
                id: busy
                asset: "images/progress/loading_compare.png"
            }
            
            ListView
            {
                id: listView
                scrollRole: ScrollRole.Main
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllArticles)
                    {
                        adm.append(data);
                        offloader.decorateTafsir(adm, "images/list/ic_chapter_tafsir.png");
                        
                        emptyDelegate.delegateActive = adm.isEmpty();
                        listView.visible = !emptyDelegate.delegateActive;
                        
                        var tab = Qt.navigationPane.parent;
                        tab.unreadContentCount = adm.size();
                        articlesPage.titleBar.title = tab.title;

                        busy.delegateActive = false;
                        tutorial.execCentered("openArticle", qsTr("This is a list of some of the articles that contain rules and regulations on how to interact with the Qur'an. Tap on one of these list items to open it.") );
                    }
                }
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        StandardListItem
                        {
                            id: rootItem
                            title: ListItemData.author
                            description: ListItemData.heading && ListItemData.heading.length > 0 ? ListItemData.heading : ListItemData.title
                            imageSource: ListItemData.imageSource
                        }
                    }
                ]
                
                onTriggered: {
                    console.log("UserEvent: ArticlePicked");
                    
                    var htd = Qt.initQml("AyatTafsirDialog.qml");
                    htd.suitePageId = dataModel.data(indexPath).id;
                    htd.open();
                }
            }
        }
        
        attachedObjects: [
            ImagePaintDefinition
            {
                id: tafseerBackground
                imageSource: "images/backgrounds/bg_chapter_tafsir_picker.amd"
            }
        ]
    }
    
    function reload() {
        busy.delegateActive = true;
        helper.fetchAllArticles(listView);
    }
    
    function cleanUp() {
        helper.textualChange.disconnect(reload);
    }
    
    onCreationCompleted: {
        helper.textualChange.connect(reload);
        reload();
    }
}