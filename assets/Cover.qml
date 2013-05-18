import bb.cascades 1.0
import com.canadainc.data 1.0

Container {
    attachedObjects: [
        ImagePaintDefinition {
            id: back
            imageSource: "images/title_bg.png"
        },

        QTimer {
            id: timer
            singleShot: false
            interval: 60000

            onTimeout: {
                updateCover();
            }
        },

        CustomSqlDataSource {
            id: sql
            source: "app/native/assets/dbase/quran.db"
            name: "cover"

            onDataLoaded: {
                if (data.length > 0) {
                    var verse = data[0];
                    label.text = "%1 (%2:%3)".arg(verse.text).arg(verse.surah_id).arg(verse.verse_id);
                } else {
                    label.text = qsTr("Quran10");
                }
            }
        }
    ]
    
    onCreationCompleted: {
        persist.settingChanged.connect(reloadNeeded);
        updateCover();
        timer.start();
    }

    function reloadNeeded(key) {
        if (key == "translation" || key == "primary") {
            updateCover()
        }
    }

    function updateCover() {
        var translation = persist.getValueFor("translation")

        if (translation != "") {
            sql.query = "select * from %1 ORDER BY RANDOM() LIMIT 1".arg(translation);
        } else {
            sql.query = "select * from arabic ORDER BY RANDOM() LIMIT 1";
        }
        
        sql.load();
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
        textStyle.fontSize: FontSize.XXSmall
        textStyle.textAlign: TextAlign.Center
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        multiline: true
    }
}