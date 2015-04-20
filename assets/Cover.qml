import bb.cascades 1.0

Container
{
    id: root
    property variant lastTime
    
    function doLookup()
    {
        var now = new Date();
        
        if (!lastTime || now-lastTime > 60000) {
            lastTime = now;
            helper.fetchRandomAyat(root);
        }
    }
    
    attachedObjects: [
        ImagePaintDefinition {
            id: back
            imageSource: "images/title/title_bg.png"
        }
    ]
    
    function onDataLoaded(id, data)
    {
        var verse = data[0];
        label.text = "(%2:%3) %1".arg(verse.text).arg(verse.surah_id).arg(verse.verse_id);
    }
    
    onCreationCompleted: {
        Application.thumbnail.connect(doLookup);
        helper.textualChange.connect(doLookup);
        doLookup();
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