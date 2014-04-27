import bb.cascades 1.0

Sheet
{
    id: root
    
    Page
    {
        titleBar: TitleBar
        {
            title: qsTr("Learn Arabic!") + Retranslate.onLanguageChanged
            
            dismissAction: ActionItem
            {
                title: qsTr("Back") + Retranslate.onLanguageChanged
                imageSource: "images/title/ic_prev.png"
                
                onTriggered: {
                    console.log("UserEvent: AlFurqanBack");
                    root.close();
                }
            }
        }
        
        ScrollView
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container
            {
                background: Color.White
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                topPadding: 10; bottomPadding: 10; rightPadding: 10; leftPadding: 10
                
                ImageView
                {
                    imageSource: "images/alfurqan/al_furqan_logo.png"
                    horizontalAlignment: HorizontalAlignment.Center
                    translationX: 1000
                    
                    animations: [
                        TranslateTransition {
                            id: tt
                            fromX: 500
                            toX: 0
                            duration: 500
                            easingCurve: StockCurve.ElasticOut
                        }
                    ]
                }
                
                Label
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    textStyle.textAlign: TextAlign.Center
                    content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                    textStyle.color: Color.Black
                    multiline: true
                    text: qsTr("Al Furqan Online Arabic Institute is an Arabic language Program that will be conducted online via Wiz IQ. These classes will be organized by your brother in Islam, Abu Asiya Ilyas Aidarus, who is a Canadian student at Umul Qura University, in Makkah, KSA. Classes will be conducted by qualified teachers who have the capability and experience of teaching the Arabic Language to non-native speakers who may be from different parts of the world. These classes will be geared towards brothers and sisters who have little to no experience with the Arabic language. This program will focus on the 4 components of learning, which are: listening, reading, writing, and speaking. A curriculum will be prepared, that will include all the necessary components to best support the student of Al Furqan E-Learning Arabic Institute and will help strengthen his/her knowledge of the Arabic language and its understanding.\n\nThe specific days and times have not yet been determined; however, will be made available to you all shortly. Classes will last for an hour and a half, four times a week. There will be a limit of 30 male students and 30 female students that will be allowed to take part in this program and those 60 students will be divided into four classrooms. There will be 15 students per classroom. Two classrooms will be for brothers and two classrooms for sisters. Students will be provided with all the required materials for the program.\n\nThe intent behind this online institute is to provide a means of learning the Arabic language with qualified Professors for both brothers and sisters whose native language is not Arabic.  We are well aware of the extreme difficulty in finding qualified Arabic teachers who can teach on a consistent basis, and we hoped to make this easier for both brothers and sisters seeking the Face of Allaah. We pray that this institute is of much benefit and we hope that this program develops into something much bigger so that many of those who wish to learn this beautiful language may be able to do so.\n\nYour brother in Islam,\n\nAbu Asiya Ilyas al Kanadi\n\nAbu Asiya Ilyas al Kanadi , Director\nAl-Furqān E-Learning Arabic Institute| Makkah, KSA\nEmail - alfurqanarabic1@gmail.com\nPhone - +966 540451248\nTwitter - @AlFurqanArabic\nPin - 2B77C09E") + Retranslate.onLanguageChanged
                    opacity: 0
                    
                    animations: [
                        FadeTransition {
                            id: fader
                            fromOpacity: 0
                            toOpacity: 1
                            easingCurve: StockCurve.CubicOut
                            duration: 1000
                        }
                    ]
                }
            }
        }
    }
    
    onOpened: {
        fader.play();
        tt.play();
    }
    
    onClosed: {
        destroy();
    }
}