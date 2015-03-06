import bb.cascades 1.0

Container
{
    id: itemRoot
    property bool peek: ListItem.view.secretPeek
    property bool selection: ListItem.selected
    property bool playing: ListItemData.playing ? ListItemData.playing : false
    property bool active: ListItem.active
    property alias secondLine: translationLabel
    horizontalAlignment: HorizontalAlignment.Fill
    
    function updateState()
    {
        if (playing) {
            background = Color.create("#ffff8c00")
        } else if (selection) {
            background = Color.DarkGreen
        } else if (active) {
            background = ListItem.view.activeDefinition.imagePaint
        } else {
            background = undefined
        }
    }
    
    onCreationCompleted: {
        selectionChanged.connect(updateState);
        playingChanged.connect(updateState);
        activeChanged.connect(updateState);
        updateState();
    }
    
    onPeekChanged: {
        if (peek) {
            showAnim.play();
        }
    }
    
    opacity: 0
    animations: [
        FadeTransition
        {
            id: showAnim
            fromOpacity: 0
            toOpacity: 1
            duration: Math.max( 200, Math.min( itemRoot.ListItem.indexPath[0]*300, 750 ) );
            easingCurve: StockCurve.QuadraticIn
        }
    ]
    
    ListItem.onInitializedChanged: {
        if (initialized) {
            showAnim.play();
        }
    }
    
    ListItem.onViewChanged: {
        if (view) {
            headerRoot.background = itemRoot.ListItem.view.background.imagePaint;
        }
    }
    
    Container
    {
        id: headerRoot
        horizontalAlignment: HorizontalAlignment.Fill
        topPadding: 5
        bottomPadding: 5
        leftPadding: 5
        
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        
        Label {
            text: "%1:%2".arg(ListItemData.surah_id).arg(ListItemData.verse_id)
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.fontSize: FontSize.XXSmall
            textStyle.color: Color.White
            textStyle.fontWeight: FontWeight.Bold
            textStyle.textAlign: TextAlign.Center
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
        }
    }
    
    Container
    {
        topPadding: 5; bottomPadding: 5; leftPadding: 5; rightPadding: 5
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill

        TextArea
        {
            id: firstLabel
            text: ListItemData.arabic
            backgroundVisible: false
            editable: false
            horizontalAlignment: HorizontalAlignment.Fill
            
            textStyle {
                color: selection || playing ? Color.White : Color.Black;
                base: global.textFont
                fontFamily: "Regular";
                textAlign: TextAlign.Right;
                fontSizeValue: itemRoot.ListItem.view.primarySize
                fontSize: FontSize.PointValue
            }
        }
        
        Label {
            id: translationLabel
            text: ListItemData.translation
            multiline: true
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.color: selection || playing ? Color.White : Color.Black
            textStyle.textAlign: TextAlign.Center
            visible: text.length > 0;
            textStyle.fontSize: {
                var translationSize = itemRoot.ListItem.view.translationSize;
                
                if (translationSize == 1) {
                    return FontSize.Small;
                } else if (translationSize == 2) {
                    return FontSize.Medium;
                } else {
                    return FontSize.XXLarge;
                }
            }
        }
    }
}