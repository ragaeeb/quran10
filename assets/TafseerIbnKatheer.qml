import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    property variant surahId
    
    onSurahIdChanged: {
        var chapterId = surahId == 114 ? 113 : surahId;
        sqlDataSource.query = "SELECT title,body FROM ibn_katheer_english WHERE surah_id=%1".arg(chapterId)
        sqlDataSource.load(98);
        
        sqlDataSource.query = "SELECT english_name, english_translation, arabic_name FROM chapters WHERE surah_id=%1".arg(surahId);
        sqlDataSource.load(1);        
    }
    
    attachedObjects: [
        CustomSqlDataSource {
            id: sqlDataSource
            source: "app/native/assets/dbase/quran.db"
            name: "ibnkatheer"

            onDataLoaded: {
                if (id == 98) {
			        adm.append(data);
                    busy.running = false;
                } else if (id == 1) {
                    surahNameArabic.text = data[0].arabic_name
                    surahNameEnglish.text = qsTr("%1 (%2)").arg(data[0].english_name).arg(data[0].english_translation);
                }
            }
        }
    ]

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

    Container
    {
        background: Color.White
        
        Container {
            id: titleBar
            
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

        ImageView {
            imageSource: "images/bottomDropShadow.png"
            topMargin: 0
            leftMargin: 0
            rightMargin: 0
            bottomMargin: 0

            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Top
        }

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

                        property bool active: ListItem.active
                        property bool selected: ListItem.selected

                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        background: active || selected ? Color.DarkGreen : undefined

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
                                textStyle.color: active || selected ? Color.White : Color.Black
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