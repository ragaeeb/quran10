import bb.cascades 1.0
import com.canadainc.data 1.0
import QtQuick 1.0

Container
{
    attachedObjects: [
        ImagePaintDefinition {
            id: back
            imageSource: "images/title_bg.png"
        },

        Timer {
            id: timer
            repeat: true
            interval: 60000
            running: true
            triggeredOnStart: true

            onTriggered: {
                helper.fetchRandomAyat(timer);
            }
        }
    ]
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchRandomAyat)
        {
            var verse = data[0];
            label.text = "(%2:%3) %1".arg(verse.text).arg(verse.surah_id).arg(verse.verse_id);
        }
    }
    
    onCreationCompleted: {
        helper.dataLoaded.connect(onDataLoaded);
    }

    background: back.imagePaint
    leftPadding: 10; rightPadding: 10; topPadding: 10; bottomPadding: 10;
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill

    layout: DockLayout {}
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        background: Color.Black
        opacity: 0.4
    }

    Label {
        id: label
        text: qsTr("Quran10") + Retranslate.onLanguageChanged
        textStyle.fontSize: FontSize.XXSmall
        textStyle.textAlign: TextAlign.Center
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        multiline: true
    }
}