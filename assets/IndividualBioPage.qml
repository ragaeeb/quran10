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
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchBio)
        {
            if (data.length > 0)
            {
                titleBar.title = data[0].name;
                var uri = data[0].uri ? data[0].uri+"\n" : "";
                body.text = data[0].biography+"\n\n"+uri;
                
                if ( body.text.trim().length == 0 ) {
                    body.text = "No biography found for individual...";
                }
            } else {
                titleBar.title = qsTr("Quran10");
                body.text = "Individual was not found...";
            }
        } else if (id == QueryId.FetchAllTafsir || id == QueryId.FetchAllQuotes) {
            adm.append(data);
            workHeader.count += data.length;
        } else if (id == QueryId.FetchAllTafsirForSuite && data.length > 0) {
            persist.invoke("com.canadainc.Quran10.tafsir.previewer", "", "", "quran://tafsir/"+data[0].id);
        }
    }
    
    titleBar: TitleBar {}
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        leftPadding: 10; rightPadding: 10
        
        TextArea
        {
            id: body
            editable: false
            backgroundVisible: false
            content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
            input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
            topPadding: 0;
            textStyle.fontSize: FontSize.Medium
            bottomPadding: 0; bottomMargin: 0
            verticalAlignment: VerticalAlignment.Fill
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
        }
        
        Header {
            id: bioHeader
            property int count: 0
            subtitle: count
            visible: count > 0
            title: qsTr("Biographies & Mentions") + Retranslate.onLanguageChanged
            bottomMargin: 0; topMargin: 0
        }
        
        ListView
        {
            id: bios
            
            dataModel: ArrayDataModel {
                id: bioModel
            }
            
            function itemType(data, indexPath)
            {
                if (data.points) {
                    return "jarwahTahdeel";
                } else {
                    return "bio";
                }
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    type: "bio"
                    
                    Container
                    {
                        id: bioContainer
                        leftPadding: 10; rightPadding: 10; bottomPadding: 10
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        
                        Label {
                            multiline: true
                            text: qsTr("%1\n\n%2").arg(ListItemData.bio).arg(ListItemData.reference) + Retranslate.onLanguageChanged
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.textAlign: TextAlign.Center
                        }
                        
                        Divider {
                            topMargin: 0; bottomMargin: 0
                            visible: itemRoot.ListItem.indexPath[0] != itemRoot.ListItem.view.dataModel.size()-1
                        }
                    }
                },
                
                ListItemComponent
                {
                    type: "jarwahTahdeel"
                    
                    StandardListItem
                    {
                        description: ListItemData.body.replace(/\n/g, " ").substr(0, 60) + "..."
                        imageSource: ListItemData.points > 0 ? "images/list/ic_like.png" : "images/list/ic_dislike.png"
                        title: ListItemData.author
                    }
                }
            ]
            
            onTriggered: {
                var d = dataModel.data(indexPath);
                
                if (d.body) {
                
                } else {
                    console.log("UserEvent: InvokeTafsir");
                    helper.fetchAllTafsirForSuite(bioPage, d.id);
                }
            }
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
        }
        
        Divider {
            topMargin: 0; bottomMargin: 0
        }
        
        Header {
            id: workHeader
            property int count: 0
            subtitle: count
            visible: count > 0
            title: qsTr("Works") + Retranslate.onLanguageChanged
            bottomMargin: 0; topMargin: 0
        }
        
        ListView
        {
            id: listView
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            function itemType(data, indexPath)
            {
                if (data.body) {
                    return "quote";
                } else {
                    return "tafsir";
                }
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    type: "quote"
                    
                    Container
                    {
                        id: itemRoot
                        leftPadding: 10; rightPadding: 10; bottomPadding: 10
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        
                        Label {
                            multiline: true
                            text: qsTr("“%1” - %2").arg(ListItemData.body).arg(ListItemData.author) + Retranslate.onLanguageChanged
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.textAlign: TextAlign.Center
                        }
                        
                        Divider {
                            topMargin: 0; bottomMargin: 0
                            visible: itemRoot.ListItem.indexPath[0] != itemRoot.ListItem.view.dataModel.size()-1
                        }
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
                }
            ]
            
            onTriggered: {
                var d = dataModel.data(indexPath);
                
                if (d.body) {
                    
                } else {
                    console.log("UserEvent: InvokeTafsir");
                    helper.fetchAllTafsirForSuite(bioPage, d.id);
                }
            }
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
        }
    }
}