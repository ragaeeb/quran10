import bb.cascades 1.0

Page {
    actions: [
        ActionItem {
            title: qsTr("Prophetic Commentary on the Qu'ran") + Retranslate.onLanguageChanged

            onTriggered: {
                invoker.invoke("bukhari/6/60");
            }
        },

        ActionItem {
            title: qsTr("Kitab Al-Tafsir") + Retranslate.onLanguageChanged

            onTriggered: {
                invoker.invoke("muslim/56");
            }
        },

        InvokeActionItem {
            query {
                mimeType: "text/html"
                uri: "http://abdurrahman.org/qurantafseer/HowWeareobliged-albanee.pdf"
                invokeActionId: "bb.action.OPEN"
            }

            title: qsTr("Interpretation") + Retranslate.onLanguageChanged
            imageSource: "images/ic_info.png"
        }
    ]

    Container {
    }
}
