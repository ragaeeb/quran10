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
            tafsirHelper.fetchIndividualData(bioPage, individualId);
            tafsirHelper.fetchTeachers(bioPage, individualId);
            tafsirHelper.fetchStudents(bioPage, individualId);
            tafsirHelper.fetchAllWebsites(bioPage, individualId);
        }
    }
    
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
        } else if (id == QueryId.RemoveTeacher) {
            persist.showToast( qsTr("Teacher removed!"), "images/menu/ic_remove_teacher.png" );
        } else if (id == QueryId.RemoveStudent) {
            persist.showToast( qsTr("Student removed!"), "images/menu/ic_remove_companions.png" );
        } else if (id == QueryId.AddTeacher) {
            persist.showToast( qsTr("Teacher added!"), "images/menu/ic_set_companions.png" );
        } else if (id == QueryId.AddStudent) {
            persist.showToast( qsTr("Student added!"), "images/menu/ic_add_student.png" );
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
                
                function removeStudent(ListItem)
                {
                    tafsirHelper.removeStudent(bioPage, individualId, ListItem.data.id);
                    bioModel.removeAt(ListItem.indexPath);
                }
                
                function removeTeacher(ListItem)
                {
                    tafsirHelper.removeTeacher(bioPage, individualId, ListItem.data.id);
                    bioModel.removeAt(ListItem.indexPath);
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
                            
                            contextMenuHandler: [
                                ContextMenuHandler {
                                    onPopulating: {
                                        if (!reporter.isAdmin) {
                                            event.abort();
                                        }
                                    }
                                }
                            ]
                            
                            contextActions: [
                                ActionSet
                                {
                                    title: teacherSli.title
                                    
                                    DeleteActionItem
                                    {
                                        imageSource: "images/menu/ic_remove_teacher.png"
                                        
                                        onTriggered: {
                                            console.log("UserEvent: RemoveTeacher");
                                            teacherSli.ListItem.view.removeTeacher(teacherSli.ListItem);
                                        }
                                    }
                                }
                            ]
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
                            
                            contextMenuHandler: [
                                ContextMenuHandler {
                                    onPopulating: {
                                        if (!reporter.isAdmin) {
                                            event.abort();
                                        }
                                    }
                                }
                            ]
                            
                            contextActions: [
                                ActionSet
                                {
                                    title: studentSli.title
                                    
                                    DeleteActionItem
                                    {
                                        imageSource: "images/menu/ic_remove_student.png"
                                        
                                        onTriggered: {
                                            console.log("UserEvent: RemoveStudent");
                                            studentSli.ListItem.view.removeStudent(studentSli.ListItem);
                                        }
                                    }
                                }
                            ]
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
        },
        
        ActionItem
        {
            id: addStudent
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_add_student.png"
            title: qsTr("Add Student") + Retranslate.onLanguageChanged
            
            function onPicked(student, name)
            {
                tafsirHelper.addStudent(bioPage, individualId, student);
                checkForDuplicate( {'id': student, 'student': name, 'type': "student"} );
            }
            
            onTriggered: {
                console.log("UserEvent: AddStudent");
                definition.source = "IndividualPickerPage.qml";
                
                var p = definition.createObject();
                p.picked.connect(onPicked);
                
                navigationPane.push(p);
            }
        },
        
        ActionItem
        {
            id: addTeacher
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_add_teacher.png"
            title: qsTr("Add Teacher") + Retranslate.onLanguageChanged
            
            function onPicked(teacher, name)
            {
                tafsirHelper.addTeacher(bioPage, individualId, teacher);
                checkForDuplicate( {'id': teacher, 'teacher': name, 'type': "teacher"} );
            }
            
            onTriggered: {
                console.log("UserEvent: AddTeacher");
                definition.source = "IndividualPickerPage.qml";
                
                var p = definition.createObject();
                p.picked.connect(onPicked);
                
                navigationPane.push(p);
            }
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
        if (reporter.isAdmin) {
            addAction(addTeacher);
            addAction(addStudent);
        }
        
        helper.textualChange.connect(reload);
    }
}