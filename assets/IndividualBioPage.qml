import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: bioPage
    property variant individualId
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onIndividualIdChanged: {
        if (individualId)
        {
            helper.fetchBio(bioPage, individualId);
            helper.fetchAllQuotes(bioPage, individualId);
            helper.fetchAllTafsir(bioPage, individualId);
            helper.fetchIndividualData(bioPage, individualId);
            helper.fetchTeachers(bioPage, individualId);
            helper.fetchStudents(bioPage, individualId);
            helper.fetchAllWebsites(bioPage, individualId);
        }
    }
    
    actions: [
        InvokeActionItem
        {
            id: shareAction
            imageSource: "images/menu/ic_share.png"
            title: qsTr("Share") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            
            onTriggered: {
                console.log("UserEvent: ShareProfile");
                data = persist.convertToUtf8( "quran://bio/"+individualId.toString() );
                reporter.record( "ShareProfile", individualId.toString() );
            }
        }
    ]
    
    function popToRoot()
    {
        while (navigationPane.top != bioPage) {
            navigationPane.pop();
        }
    }
    
    function checkForDuplicate(result)
    {
        var indexPath = bioModel.findExact(result);
        
        if (indexPath.length == 0) {
            bioModel.insert(result);
        }
        
        popToRoot();
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchAllTafsirForSuite && data.length > 0) {
            persist.invoke( "com.canadainc.Quran10.tafsir.previewer", "", "", "quran://tafsir/"+data[0].id.toString() );
        } else if (id == QueryId.FetchIndividualData && data.length > 0) {
            var metadata = data[0];
            
            var result = "";
            
            if (metadata.prefix) {
                result += metadata.prefix+" ";
            }
            
            result += metadata.name;
            
            titleBar.title = metadata.name;
            
            if (metadata.kunya) {
                result += " (%1)".arg(metadata.kunya);
            }
            
            result += " ";
            
            if (metadata.birth && metadata.death) {
                result += "(%1)".arg( global.getHijriYear(metadata.birth, metadata.death) );
            } else if (metadata.birth) {
                result += qsTr("(born %1)").arg( global.getHijriYear(metadata.birth) );
            } else if (metadata.death) {
                result += qsTr("(died %1)").arg( global.getHijriYear(metadata.death) );
            }
            
            result += "\n";

            body.text = "\n"+result;
            ft.play();
        }
        
        data = offloader.fillType(data, id);
        bioModel.insertList(data);
    }
    
    titleBar: TitleBar {
        scrollBehavior: TitleBarScrollBehavior.NonSticky
    }
    
    Container
    {
        layout: DockLayout {}
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        background: bg.imagePaint
        
        Container
        {
            background: Color.Black
            opacity: 0
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            animations: [
                FadeTransition {
                    id: ft
                    fromOpacity: 0
                    toOpacity: 0.5
                    easingCurve: StockCurve.SineOut
                    duration: 2000
                }
            ]
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            TextArea
            {
                id: body
                editable: false
                backgroundVisible: false
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff
                topPadding: 0;
                textStyle.fontSize: FontSize.Large
                bottomPadding: 0; bottomMargin: 0
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
                textStyle.fontWeight: FontWeight.Bold
                textStyle.fontStyle: FontStyle.Italic
                visible: text.length > 0
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: -1
                }
            }
            
            ImageView {
                topMargin: 0; bottomMargin: 0
                imageSource: "images/dividers/divider_bio_page.png"
                horizontalAlignment: HorizontalAlignment.Center
            }
            
            ListView
            {
                id: bios
                property variant editIndexPath
                scrollRole: ScrollRole.Main
                
                layout: StackListLayout {
                    headerMode: ListHeaderMode.Sticky
                }
                
                dataModel: GroupDataModel
                {
                    id: bioModel
                    sortingKeys: ["type", "uri", "teacher", "student"]
                    grouping: ItemGrouping.ByFullValue
                }
                
                function getHeaderName(ListItemData)
                {
                    if (ListItemData == "bio") {
                        return qsTr("Biographies");
                    } else if (ListItemData == "citing") {
                        return qsTr("Citings");
                    } else if (ListItemData == "tafsir") {
                        return qsTr("Works");
                    } else if (ListItemData == "teacher") {
                        return qsTr("Teachers");
                    } else if (ListItemData == "student") {
                        return qsTr("Students");
                    } else if (ListItemData == "website") {
                        return qsTr("Websites");
                    } else if (ListItemData == "email") {
                        return qsTr("Email Addresses");
                    } else if (ListItemData == "phone") {
                        return qsTr("Phone Numbers");
                    } else {
                        return qsTr("Quotes");
                    }
                }
                
                function itemType(data, indexPath)
                {
                    if (indexPath.length == 1) {
                        return "header";
                    } else {
                        return data.type;
                    }
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        type: "header"
                        
                        Header
                        {
                            id: header
                            title: header.ListItem.view.getHeaderName(ListItemData)
                            subtitle: header.ListItem.view.dataModel.childCount(header.ListItem.indexPath)
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "bio"
                        
                        StandardListItem
                        {
                            description: ListItemData.heading ? ListItemData.heading : ListItemData.title ? ListItemData.title : ""
                            imageSource: ListItemData.points > 0 ? "images/list/ic_like.png" : ListItemData.points < 0 ? "images/list/ic_dislike.png" : "images/list/ic_bio.png"
                            title: ListItemData.author ? ListItemData.author : ListItemData.reference ? ListItemData.reference : ""
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "citing"
                        
                        StandardListItem
                        {
                            description: ListItemData.heading ? ListItemData.heading : ListItemData.title ? ListItemData.title : ""
                            imageSource: "images/list/ic_tafsir.png"
                            title: ListItemData.author ? ListItemData.author : ListItemData.reference ? ListItemData.reference : ""
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "quote"
                        
                        TextArea {
                            backgroundVisible: false
                            editable: false
                            input.flags: TextInputFlag.SpellCheckOff
                            content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                            text: "“%1” (%2)".arg(ListItemData.body).arg(ListItemData.reference) + Retranslate.onLanguageChanged
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.textAlign: TextAlign.Center
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "tafsir"
                        
                        StandardListItem
                        {
                            description: ListItemData.author
                            imageSource: "images/list/ic_rijaal_quote.png"
                            title: ListItemData.title
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "teacher"
                        
                        StandardListItem
                        {
                            id: teacherSli
                            imageSource: "images/list/ic_teacher.png"
                            title: ListItemData.teacher
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "student"
                        
                        StandardListItem
                        {
                            id: studentSli
                            imageSource: "images/list/ic_student.png"
                            title: ListItemData.student
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "website"
                        
                        StandardListItem
                        {
                            imageSource: ListItemData.imageSource
                            title: ListItemData.uri
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "phone"
                        
                        StandardListItem
                        {
                            imageSource: "images/list/ic_phone.png"
                            title: ListItemData.uri
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "email"
                        
                        StandardListItem
                        {
                            imageSource: "images/list/ic_email.png"
                            title: ListItemData.uri
                        }
                    }
                ]
                
                onTriggered: {
                    if (indexPath.length == 1) {
                        console.log("UserEvent: HeaderTapped");
                        return;
                    }
                    
                    var d = dataModel.data(indexPath);
                    console.log("UserEvent: AttributeTapped", d.type);
                    
                    if (d.type == "student" || d.type == "teacher") {
                        persist.invoke( "com.canadainc.Quran10.bio.previewer", "", "", "", d.id.toString() );
                    } else if (d.type == "bio" || d.type == "citing") {
                        persist.invoke( "com.canadainc.Quran10.tafsir.previewer", "", "", "quran://tafsir/"+d.suite_page_id.toString() );
                    } else if (d.type == "tafsir") {
                        console.log("UserEvent: InvokeTafsir");
                        helper.fetchAllTafsirForSuite(bioPage, d.id);
                    } else if (d.type == "website") {
                        persist.openUri(d.uri);
                    } else if (d.type == "phone") {
                        persist.call(d.uri);
                    } else if (d.type == "email") {
                        persist.invoke("", "", "", "mailto:"+d.uri);
                    }
                    
                    reporter.record("BioTapped", individualId+":"+d.type);
                }
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
            }
        }
    }
    
    attachedObjects: [
        ImagePaintDefinition
        {
            id: bg
            imageSource: "images/backgrounds/background_ayat_page.jpg"
        },
        
        ComponentDefinition {
            id: definition
        }
    ]
    
    function reload()
    {
        bioModel.clear();
        individualIdChanged();
    }
    
    function cleanUp() {
        helper.textualChange.disconnect(reload);
    }
    
    onCreationCompleted: {
        helper.textualChange.connect(reload);
    }
}