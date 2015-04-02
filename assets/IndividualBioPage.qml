import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: bioPage
    property variant individualId
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onIndividualIdChanged: {
        helper.fetchBio(bioPage, individualId);
        helper.fetchAllQuotes(bioPage, individualId);
        helper.fetchAllTafsir(bioPage, individualId);
        tafsirHelper.fetchIndividualData(bioPage, individualId);
        tafsirHelper.fetchMentions(bioPage, individualId);
        tafsirHelper.fetchTeachers(bioPage, individualId);
        tafsirHelper.fetchStudents(bioPage, individualId);
        tafsirHelper.fetchAllWebsites(bioPage, individualId);
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
            
            if (metadata.displayName) {
                titleBar.title = metadata.displayName;
            } else {
                titleBar.title = metadata.name;
            }
            
            if (metadata.kunya) {
                result += " (%1)".arg(metadata.kunya);
            }
            
            result += " ";
            
            if (metadata.birth && metadata.death) {
                result += qsTr("(%1-%2 AH)").arg(metadata.birth).arg(metadata.death);
            } else if (metadata.birth) {
                result += qsTr("(born %1 AH)").arg(metadata.birth);
            } else if (metadata.death) {
                result += qsTr("(died %1 AH)").arg(metadata.death);
            }
            
            result += "\n";

            body.text = "\n"+result;
            ft.play();
        }
        
        offloader.fillType(data, id, bioModel);
    }
    
    titleBar: TitleBar {}
    
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
                content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
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
            
            Divider {
                topMargin: 0; bottomMargin: 0
            }
            
            ListView
            {
                id: bios
                
                layout: StackListLayout {
                    headerMode: ListHeaderMode.Sticky
                }
                
                dataModel: GroupDataModel
                {
                    id: bioModel
                    sortingKeys: ["type"]
                    grouping: ItemGrouping.ByFullValue
                }
                
                function getHeaderName(ListItemData)
                {
                    if (ListItemData == "mention") {
                        return qsTr("Mentions");
                    } else if (ListItemData == "bio") {
                        return qsTr("Biographies");
                    } else if (ListItemData == "tafsir") {
                        return qsTr("Explanations");
                    } else if (ListItemData == "teacher") {
                        return qsTr("Teachers");
                    } else if (ListItemData == "student") {
                        return qsTr("Students");
                    } else if (ListItemData == "website") {
                        return qsTr("Websites");
                    } else  {
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
                        
                        Container
                        {
                            id: bioContainer
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            
                            TextArea
                            {
                                editable: false
                                backgroundVisible: false
                                content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                                input.flags: TextInputFlag.SpellCheckOff
                                text: qsTr("%1\n%2").arg(ListItemData.bio).arg(ListItemData.reference) + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Fill
                                textStyle.textAlign: TextAlign.Center
                            }
                            
                            Divider {
                                topMargin: 0; bottomMargin: 0
                                visible: bioContainer.ListItem.indexPath != bioContainer.ListItem.view.dataModel.last()
                            }
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "mention"
                        
                        StandardListItem
                        {
                            description: ListItemData.body.replace(/\n/g, " ").substr(0, 60) + "..."
                            imageSource: ListItemData.points > 0 ? "images/list/ic_like.png" : "images/list/ic_dislike.png"
                            title: ListItemData.author
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
                            text: qsTr("“%1” (%2)").arg(ListItemData.body).arg(ListItemData.reference) + Retranslate.onLanguageChanged
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
                            imageSource: "images/list/ic_tafsir.png"
                            title: ListItemData.title
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "teacher"
                        
                        StandardListItem
                        {
                            imageSource: "images/list/ic_teacher.png"
                            title: ListItemData.teacher
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "student"
                        
                        StandardListItem
                        {
                            imageSource: "images/list/ic_student.png"
                            title: ListItemData.student
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "website"
                        
                        StandardListItem
                        {
                            id: sli
                            imageSource: ListItemData.imageSource
                            description: ListItemData.uri
                        }
                    }
                ]
                
                onTriggered: {
                    var d = dataModel.data(indexPath);
                    console.log("UserEvent: AttributeTriggered", d.type);
                    
                    if (d.type == "student" || d.type == "teacher") {
                        persist.invoke( "com.canadainc.Quran10.bio.previewer", "", "", "", d.id.toString() );
                    } else if (d.type == "tafsir") {
                        console.log("UserEvent: InvokeTafsir");
                        helper.fetchAllTafsirForSuite(bioPage, d.id);
                    } else if (d.type == "website") {
                        persist.donate(d.uri);
                    }
                }
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
            }
        }
    }
    
    attachedObjects: [
        ImagePaintDefinition {
            id: bg
            imageSource: "images/backgrounds/background_ayat_page.jpg"
        }
    ]
}