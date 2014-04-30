import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: root
    property string tafsirId
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onTafsirIdChanged: {
        helper.fetchTafsirContent(root, tafsirId);
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchTafsirContent)
        {
            contentLabel.text = data[0].text+"\n\n";
            descriptionLabel.text = data[0].description;
            
            var explainer = data[0].explainer;
            var recorder = data[0].recorder;
            var authorText = qsTr("Author: %1").arg(explainer);
            
            if (recorder.length > 0) {
                authorText += "\n";
                authorText += qsTr("Recorded/Translated by: %1").arg(recorder)
            }
            
            authorLabel.text = authorText
        }
    }
    
    titleBar: TitleBar
    {
        kind: TitleBarKind.FreeForm
        
        kindProperties: FreeFormTitleBarKindProperties
        {
            content: Container
            {
                topPadding: 15
                leftPadding: 10
                rightPadding: 10
                
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
                background: back.imagePaint
                
                attachedObjects: [
                    ImagePaintDefinition {
                        id: back
                        imageSource: "images/title/title_bg_alt.png"
                    }
                ]
                
                Label {
                    id: descriptionLabel
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSize: FontSize.XXSmall
                    textStyle.fontWeight: FontWeight.Bold
                    multiline: true
                    bottomMargin: 5
                }
                
                Label {
                    id: authorLabel
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSize: FontSize.XXSmall
                    textStyle.fontWeight: FontWeight.Bold
                    multiline: true
                    topMargin: 0
                }
            }
        }
    }
    
    ScrollView
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        Container
        {
            leftPadding: 20
            rightPadding: 20
            background: Color.White
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Label
            {
                id: contentLabel
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Top
                textStyle.color: Color.Black
                multiline: true
            }
        }
    }
}