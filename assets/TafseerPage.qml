import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    property string tafsirId
    
    onTafsirIdChanged: {
        sqlDataSource.query = "SELECT * from tafsir_english WHERE id=%1".arg(tafsirId);
        sqlDataSource.load(0);
    }
    
    Container
    {
        background: Color.White
        
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill

        Container {
            topPadding: 10
            bottomPadding: 25
            leftPadding: 20
            rightPadding: 20

            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Top
            background: back.imagePaint

            attachedObjects: [
                ImagePaintDefinition {
                    id: back
                    imageSource: "images/title_bg_alt.png"
                }
            ]

            Label {
                id: descriptionLabel
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.XXSmall
                textStyle.fontWeight: FontWeight.Bold
                multiline: true
                bottomMargin: 5
            }

            Label {
                id: authorLabel
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.XXSmall
                textStyle.fontWeight: FontWeight.Bold
                multiline: true
                topMargin: 0
            }
        }

        Divider {
            topMargin: 0; bottomMargin: 0;
        }
        
        ScrollView
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill

			Container
			{
                leftPadding: 20
                rightPadding: 20

                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill

                Label {
                    id: contentLabel
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Top
                    textStyle.color: Color.Black
                    multiline: true
                }
            }
        }
    }
    
    attachedObjects: [
        CustomSqlDataSource {
            id: sqlDataSource
            source: "app/native/assets/dbase/quran.db"
            name: "tafseer"

            onDataLoaded: {
                if (id == 0) {
                    contentLabel.text = data[0].text;
                    descriptionLabel.text = data[0].description;
                    
                    var explainer = data[0].explainer;
                    var recorder = data[0].recorder;
                    var authorText = qsTr("Author: %1").arg(explainer);
                    
                    if (recorder.length > 0) {
                        authorText += "\n";
                        authorText += qsTr("Recorded by: %1").arg(authorText)
                    }
                    
                    authorLabel.text = authorText
                }
            }
        }
    ]
}