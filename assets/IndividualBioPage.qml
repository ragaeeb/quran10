import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: bioPage
    property variant individualId
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onIndividualIdChanged: {
        helper.fetchBio(bioPage, individualId);
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchBio)
        {
            if (data.length > 0)
            {
                titleBar.title = data[0].name;
                body.text = "\n\n"+data[0].biography+"\n\n"+data[0].uri+"\n\n";
                
                if ( body.text.trim().length == 0 ) {
                    body.text = "\nNo biography found for individual...";
                }
            } else {
                titleBar.title = qsTr("Quran10");
                body.text = "\nIndividual was not found...";
            }
        }
    }
    
    titleBar: TitleBar {}
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        leftPadding: 10; rightPadding: 10
        
        TextArea
        {
            id: body
            editable: false
            backgroundVisible: false
            content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
            input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
            topPadding: 0;
            textStyle.fontSize: FontSize.Medium
            bottomPadding: 0; bottomMargin: 0
            verticalAlignment: VerticalAlignment.Fill
        }
    }
}