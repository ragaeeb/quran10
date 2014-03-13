import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: root
    property int surahId
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchTafsirIbnKatheerForSurah) {
            adm.append(data);
            busy.running = false;
        } else if (id == QueryId.FetchSurahHeader) {
            console.log("actual data", data[0].arabic_name, data[0].english_name);
            surahNameArabic.text = data[0].arabic_name
            surahNameEnglish.text = qsTr("%1 (%2)").arg(data[0].english_name).arg(data[0].english_translation);
        }
    }
    
    onCreationCompleted: {
        helper.dataLoaded.connect(onDataLoaded);
    }
    
    onSurahIdChanged: {
        helper.fetchSurahHeader(root, surahId);
        helper.fetchTafsirIbnKatheer(root, surahId);
    }

    actions: [
        ActionItem {
            title: qsTr("Top") + Retranslate.onLanguageChanged
            imageSource: "file:///usr/share/icons/ic_go.png"
            ActionBar.placement: ActionBarPlacement.OnBar

            onTriggered: {
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Default);
            }
        },

        ActionItem {
            title: qsTr("Bottom") + Retranslate.onLanguageChanged
            imageSource: "images/ic_scroll_end.png"
            ActionBar.placement: ActionBarPlacement.OnBar

            onTriggered: {
                listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Default);
            }
        }
    ]
    
    titleBar: TitleBar
    {
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties
        {
            content: Container
            {
                topPadding: 10; bottomPadding: 25
                
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Top
                background: back.imagePaint
                
                attachedObjects: [
                    ImagePaintDefinition {
                        id: back
                        imageSource: "images/title_bg_tafseer.amd"
                    }
                ]
                
                Label {
                    id: surahNameArabic
                    horizontalAlignment: HorizontalAlignment.Fill
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSize: FontSize.XXSmall
                    textStyle.fontWeight: FontWeight.Bold
                    bottomMargin: 5
                }
                
                Label {
                    id: surahNameEnglish
                    horizontalAlignment: HorizontalAlignment.Fill
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSize: FontSize.XXSmall
                    textStyle.fontWeight: FontWeight.Bold
                    topMargin: 0
                }
            }
        }
    }

    Container
    {
        background: Color.White
        
        ActivityIndicator {
            id: busy
            running: true
            visible: running
            preferredHeight: 250
            horizontalAlignment: HorizontalAlignment.Center
        }

        ListView {
            id: listView
            property variant background: headerBackground

            attachedObjects: [
                ImagePaintDefinition {
                    id: headerBackground
                    imageSource: "images/header_bg.png"
                }
            ]

            dataModel: ArrayDataModel {
                id: adm
            }

            function copyItem(ListItemData) {
                persist.copyToClipboard(qsTr("%1\n\n%2").arg(ListItemData.title).arg(ListItemData.body));
            }

            function shareItem(ListItemData) {
                var result = qsTr("%1\n\n%2").arg(ListItemData.title).arg(ListItemData.body);
                result = persist.convertToUtf8(result);
                return result;
            }

            listItemComponents: [
                ListItemComponent {
                    Container {
                        id: tafsirItemRoot

                        property bool selected: ListItem.selected

                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        background: selected ? Color.DarkGreen : undefined

                        Container {
                            background: tafsirItemRoot.ListItem.view.background.imagePaint
                            horizontalAlignment: HorizontalAlignment.Fill
                            topPadding: 5
                            bottomPadding: 5
                            leftPadding: 5

                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }

                            Label {
                                id: headerLabel
                                text: ListItemData.title
                                horizontalAlignment: HorizontalAlignment.Fill
                                textStyle.fontSize: FontSize.XXSmall
                                textStyle.color: Color.White
                                textStyle.fontWeight: FontWeight.Bold
                                textStyle.textAlign: TextAlign.Center
                                multiline: true

                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                        }

                        Container {
                            topPadding: 5
                            bottomPadding: 5
                            leftPadding: 5
                            rightPadding: 5
                            horizontalAlignment: HorizontalAlignment.Fill
                            preferredWidth: 1280

                            Label {
                                id: bodyLabel
                                text: ListItemData.body
                                multiline: true
                                horizontalAlignment: HorizontalAlignment.Fill
                                textStyle.color: selected ? Color.White : Color.Black
                                textStyle.textAlign: TextAlign.Center
                            }
                        }

                        contextActions: [
                            ActionSet {
                                title: headerLabel.text
                                subtitle: bodyLabel.text

                                ActionItem {
                                    title: qsTr("Copy") + Retranslate.onLanguageChanged
                                    imageSource: "images/ic_copy.png"
                                    onTriggered: {
                                        tafsirItemRoot.ListItem.view.copyItem(ListItemData)
                                    }
                                }

                                InvokeActionItem {
                                    title: qsTr("Share") + Retranslate.onLanguageChanged

                                    query {
                                        mimeType: "text/plain"
                                        invokeActionId: "bb.action.SHARE"
                                    }

                                    onTriggered: {
                                        data = tafsirItemRoot.ListItem.view.shareItem(ListItemData)
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
        }
    }
}