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
                
                onEnded: {
                    tutorial.execBelowTitleBar("constraintTip", qsTr("There are two kinds of constraints: You can either choose 'AND' or 'OR'.").arg(included.title), 0, "l" );
                    tutorial.execBelowTitleBar("constraintTip2", qsTr("If you want to search for a verse which has the words 'life' AND 'give' AND 'death' in it, you would enter the three words into the three text fields by tapping on the 'Add' action twice, and use the AND constraint."), 0, "l", undefined, "images/dropdown/search_and.png" );
                    tutorial.execBelowTitleBar("constraintTip3", qsTr("If you want to search for a verse which has the words 'life' OR 'give' then you would enter the two words into the two text fields by adding the 'Add' action once, and use the OR constraint."), 0, "l", undefined, "images/dropdown/search_or.png" );
                }
            }
        ]
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 0.25
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