import bb.cascades 1.0

Container
{
    property alias queryValue: queryField.text
    property alias textField: queryField
    signal startSearch()
    horizontalAlignment: HorizontalAlignment.Fill
    topMargin: 0
    translationY: -100

    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    Button
    {
        text: andMode ? qsTr("AND") + Retranslate.onLanguageChanged : qsTr("OR") + Retranslate.onLanguageChanged
        rightMargin: 0
        translationX: -200
        imageSource: andMode ? "images/dropdown/search_and.png" : "images/dropdown/search_or.png"
        
        onClicked: {
            andMode = !andMode;
        }
        
        animations: [
            TranslateTransition
            {
                id: rotator
                fromX: -200
                toX: 0
                duration: 750
                easingCurve: StockCurve.QuarticOut
            }
        ]
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 0.2
        }
    }
    
    TextField
    {
        id: queryField
        hintText: qsTr("Enter search query") + Retranslate.onLanguageChanged
        leftMargin: 0
        
        input {
            submitKey: SubmitKey.Search
            flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
            submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            
            onSubmitted: {
                startSearch();
            }
        }
        
        onCreationCompleted: {
            input["keyLayout"] = 7;
        }
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
    }
    
    animations: [
        TranslateTransition {
            fromY: -100
            toY: 0
            easingCurve: StockCurve.QuinticOut
            duration: 750
            
            onCreationCompleted: {
                play();
            }
            
            onEnded: {
                rotator.play();
                queryField.requestFocus();
            }
        }
    ]
}