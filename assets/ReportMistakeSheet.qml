import bb.cascades 1.0

Sheet
{
    id: root
    property int surahId
    property int verseId
    property string body
    property alias expectedText: expectedField.text
    
    Page
    {
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        actions: [
            DeleteActionItem
            {
                imageSource: "images/menu/ic_undo.png"
                title: qsTr("Reset") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: ResetReportMistakeTriggered");
                    
                    var confirmed = persist.showBlockingDialog( qsTr("Confirmation"), qsTr("Are you sure you want to reset all the fields?") );
                    
                    if (confirmed)
                    {
                        actual.text = body;
                        commentsField.resetText();
                        emailField.resetText();
                        expectedField.resetText();
                    }
                }
            }
        ]
        
        titleBar: TitleBar
        {
            title: qsTr("Report Error") + Retranslate.onLanguageChanged
            
            acceptAction: ActionItem
            {
                imageSource: "images/title/ic_accept.png"
                title: qsTr("Send") + Retranslate.onLanguageChanged
                enabled: typeDropDown.selectedOptionSet && emailValidator.valid && actual.text.length > 0 && (expectedField.text.length > 0 || commentsField.text.length > 0)
                
                onTriggered: {
                    console.log("UserEvent: SendReportTriggered");
                    
                    enabled = false;
                    scrollView.scrollToPoint(0, 0, ScrollAnimation.Smooth);
                    progressIndicator.visible = true;
                    var notes = "mistake_type:%1;email_address:%2;expected_value:%3;actual_value:%4;user_comments:%5;surahId:%6;verseId:%7".arg(typeDropDown.selectedValue).arg( emailField.text.trim() ).arg( expectedField.text.trim() ).arg( actual.text.trim() ).arg( commentsField.text.trim() ).arg(surahId).arg(verseId);
                    reporter.submitLogs(notes);
                }

                function onSubmitted(message)
                {
                    progressIndicator.visible = false;
                    persist.showToast( message, qsTr("OK"), "asset:///images/menu/ic_report_error.png" );
                    enabled = true;

                    root.close();
                }
                
                onCreationCompleted: {
                    reporter.submitted.connect(onSubmitted);
                }
            }
            
            dismissAction: ActionItem
            {
                imageSource: "images/title/ic_cancel.png"
                title: qsTr("Cancel") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: CancelTriggered");
                    root.close();
                }
            }
        }
        
        ScrollView
        {
            id: scrollView
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                leftPadding: 10; rightPadding: 10; topPadding: 10
                
                ProgressIndicator
                {
                    id: progressIndicator
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    value: 0
                    fromValue: 0
                    toValue: 100
                    opacity: value/100
                    state: ProgressIndicatorState.Progress
                    topMargin: 0; bottomMargin: 0; leftMargin: 0; rightMargin: 0;
                    visible: false
                    
                    function onNetworkProgressChanged(cookie, current, total)
                    {
                        value = current;
                        toValue = total;
                    }
                    
                    onCreationCompleted: {
                        reporter.progress.connect(onNetworkProgressChanged);
                    }
                }
                
                DropDown
                {
                    id: typeDropDown
                    title: qsTr("Error Type") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    Option {
                        text: qsTr("Spelling Mistake") + Retranslate.onLanguageChanged
                        description: qsTr("Typo in the Arabic or English") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/report_typo.png"
                        value: "typo"
                    }
                    
                    Option {
                        text: qsTr("Incomplete Text") + Retranslate.onLanguageChanged
                        description: qsTr("The narration is missing a portion that is supposed to be there") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/report_incomplete.png"
                        value: "incomplete"
                    }
                    
                    Option {
                        text: qsTr("Mistranslation") + Retranslate.onLanguageChanged
                        description: qsTr("The translation is incorrect") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/report_mistranslation.png"
                        value: "mistranslation"
                    }
                    
                    Option {
                        text: qsTr("Other") + Retranslate.onLanguageChanged
                        description: qsTr("Any other issues") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/report_other.png"
                        value: "other"
                    }
                }
                
                Header
                {
                    title: qsTr("Your email address") + Retranslate.onLanguageChanged
                }
                
                TextField
                {
                    id: emailField
                    hintText: qsTr("In case we need more information from you") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    input.submitKey: SubmitKey.Next
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                    inputMode: TextFieldInputMode.EmailAddress
                    
                    validator: Validator
                    {
                        id: emailValidator
                        errorMessage: qsTr("Invalid email address entered") + Retranslate.onLanguageChanged
                        mode: ValidationMode.Immediate
                        valid: false
                        
                        onValidate: {
                            var emailRegex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                            valid = emailRegex.test( emailField.text.trim() );
                        }
                    }
                }
                
                Header {
                    title: qsTr("Expected text") + Retranslate.onLanguageChanged
                }
                
                TextArea {
                    id: expectedField
                    hintText: qsTr("What you believe the text should have been") + Retranslate.onLanguageChanged
                    minHeight: 150
                    inputMode: TextAreaInputMode.Text
                    //textStyle.base: collections.textFont
                    content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                    input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                }
                
                Header {
                    title: qsTr("Actual text") + Retranslate.onLanguageChanged
                }
                
                TextArea {
                    id: actual
                    hintText: qsTr("What the incorrect text actually was") + Retranslate.onLanguageChanged
                    text: body
                    inputMode: TextAreaInputMode.Text
                    content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                    input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                }
                
                Header {
                    title: qsTr("Details/Comments") + Retranslate.onLanguageChanged
                }
                
                TextArea {
                    id: commentsField
                    hintText: qsTr("Any additional details and comments you feel are necessary") + Retranslate.onLanguageChanged
                    minHeight: 150
                    inputMode: TextAreaInputMode.Text
                    content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                }
            }
        }
    }
    
    onOpened: {
        typeDropDown.expanded = true;
    }
    
    onClosed: {
        root.destroy();
    }
}