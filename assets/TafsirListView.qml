import bb.cascades 1.0

ListView {
    property variant background: headerBackground
    property alias dm: arrayDataModel

    attachedObjects: [
        ImagePaintDefinition {
            id: headerBackground
            imageSource: "images/header_bg.png"
        }
    ]

    dataModel: ArrayDataModel {
        id: arrayDataModel
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

                        ActionItem {
                            title: qsTr("Top") + Retranslate.onLanguageChanged
                            imageSource: "file:///usr/share/icons/ic_go.png"

                            onTriggered: {
                                tafsirItemRoot.ListItem.view.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Default)
                            }
                        }

                        ActionItem {
                            title: qsTr("Bottom") + Retranslate.onLanguageChanged
                            imageSource: "images/ic_scroll_end.png"

                            onTriggered: {
                                tafsirItemRoot.ListItem.view.scrollToPosition(ScrollPosition.End, ScrollAnimation.Default)
                            }
                        }
                    }
                ]
            }
        }
    ]
}