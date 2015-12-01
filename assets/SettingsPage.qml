import bb.cascades 1.2
import bb.cascades.pickers 1.0
import com.canadainc.data 1.0

Page
{
    id: settingsPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    function cleanUp()
    {
    }
    
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        ScrollView
        {  
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            scrollRole: ScrollRole.Main
            
            Container
            {
                leftPadding: 10
                topPadding: 10
                rightPadding: 10
                bottomPadding: 10
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                PersistDropDown
                {
                    id: translation
                    title: qsTr("Translation") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    key: "translation"
                    
                    Option {
                        id: none
                        text: qsTr("None") + Retranslate.onLanguageChanged
                        description: qsTr("Do not show any additional languages.") + Retranslate.onLanguageChanged
                        value: "arabic"
                        imageSource: "images/dropdown/ic_delete.png"
                    }
                    
                    Option {
                        text: qsTr("Albanian") + Retranslate.onLanguageChanged
                        description: qsTr("Sherif Ahmeti") + Retranslate.onLanguageChanged
                        value: "albanian"
                        imageSource: "images/dropdown/flags/albanian.jpg"
                    }
                    
                    Option {
                        text: qsTr("Bengali") + Retranslate.onLanguageChanged
                        description: qsTr("Muhiuddin Khan") + Retranslate.onLanguageChanged
                        value: "bengali"
                        imageSource: "images/dropdown/flags/bengali.jpg"
                    }
                    
                    Option {
                        text: qsTr("Bosnian") + Retranslate.onLanguageChanged
                        description: qsTr("Besim Korkut") + Retranslate.onLanguageChanged
                        value: "bosnian"
                        imageSource: "images/dropdown/flags/bosnian.jpg"
                    }
                    
                    Option {
                        id: english
                        text: qsTr("English") + Retranslate.onLanguageChanged
                        description: qsTr("Muhammad al-Hilali & Muhsin Khan") + Retranslate.onLanguageChanged
                        value: "english"
                        imageSource: "images/dropdown/ic_transliteration.png"
                    }
                    
                    Option {
                        text: qsTr("French") + Retranslate.onLanguageChanged
                        description: qsTr("Muhammad Hamidullah") + Retranslate.onLanguageChanged
                        value: "french"
                        imageSource: "images/dropdown/ic_translation.png"
                    }
                    
                    Option {
                        text: qsTr("German") + Retranslate.onLanguageChanged
                        description: qsTr("A. S. F. Bubenheim and N. Elyas") + Retranslate.onLanguageChanged
                        value: "german"
                        imageSource: "images/dropdown/flags/german.jpg"
                    }
                    
                    Option {
                        text: qsTr("Hausa") + Retranslate.onLanguageChanged
                        description: qsTr("Abubakar Mahmoud Gumi") + Retranslate.onLanguageChanged
                        value: "hausa"
                        imageSource: "images/dropdown/flags/hausa.jpg"
                    }
                    
                    Option {
                        text: qsTr("Indonesian") + Retranslate.onLanguageChanged
                        description: qsTr("Indonesian Ministry of Religious Affairs") + Retranslate.onLanguageChanged
                        value: "indo"
                        imageSource: "images/dropdown/flags/indo.jpg"
                    }
                    
                    Option {
                        text: qsTr("Russian") + Retranslate.onLanguageChanged
                        description: qsTr("Elmir Kuliev (with Abd ar-Rahman as-Saadi's commentaries)") + Retranslate.onLanguageChanged
                        value: "russian"
                        imageSource: "images/dropdown/flags/russian.jpg"
                    }
                    
                    Option {
                        text: qsTr("Spanish") + Retranslate.onLanguageChanged
                        description: qsTr("Julio Cortes") + Retranslate.onLanguageChanged
                        value: "spanish"
                        imageSource: "images/dropdown/ic_translation.png"
                    }
                    
                    Option {
                        id: thai
                        text: qsTr("Thai") + Retranslate.onLanguageChanged
                        description: qsTr("King Fahd Complex") + Retranslate.onLanguageChanged
                        value: "thai"
                        imageSource: "images/dropdown/flags/thai.jpg"
                    }
                    
                    Option {
                        text: qsTr("Urdu") + Retranslate.onLanguageChanged
                        description: qsTr("Muhammad Junagarhi") + Retranslate.onLanguageChanged
                        value: "urdu"
                        imageSource: "images/dropdown/flags/urdu.jpg"
                    }
                    
                    Option {
                        text: qsTr("Uyghur") + Retranslate.onLanguageChanged
                        description: qsTr("Muhammad Saleh") + Retranslate.onLanguageChanged
                        value: "uyghur"
                        imageSource: "images/dropdown/flags/uyghur.jpg"
                    }
                    
                    onSelectedOptionChanged: {
                        if (selectedOption == none) {
                            infoText.text = qsTr("No translation will be displayed.") + Retranslate.onLanguageChanged
                        } else if (selectedOption == english) {
                            infoText.text = qsTr("Translation will be provided in %1 by %2. Please see why this is the only English translation we support:\nhttp://canadainc.org/hosting/quran_10/english_translation.htm").arg(selectedOption.text).arg(selectedOption.description) + Retranslate.onLanguageChanged
                            infoText.content.flags = TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff;
                        } else {
                            infoText.text = qsTr("Translation will be provided in %1 by %2.").arg(selectedOption.text).arg(selectedOption.description) + Retranslate.onLanguageChanged
                        }
                    }
                    
                    onValueChanged: {
                        if (diff) {
                            reporter.record("Translation", translation.selectedValue);
                        }
                    }
                    
                    onExpandedChanged: {
                        if (expanded) {
                            tutorial.execCentered( "authenticTranslation", qsTr("Some users have inquired why we do not support certain translations of the Qur'an. Please note that we are doing our best to only support the most authentic and accurate translations of the Qur'an, which are provided by Saudi Arabia's King Fahd Complex (the original Mushaf publishers).\n\nWe do not support any translations which were done by literal, or linguistic, or intellectual derivations, and rather we support the translations which were verified using the understanding of the Companions of the Messenger (sallalahu alayhi wa'sallam) and the scholars who followed them in the correct understanding."), "images/toast/ic_info.png" );
                        }
                    }
                }
                
                DropDown
                {
                    id: reciter
                    title: qsTr("Reciter") + Retranslate.onLanguageChanged
                    
                    onExpandedChanged: {
                        if (expanded) {
                            tutorial.execCentered( "qareeTazkiyyat", qsTr("Some users have inquired why we do not support certain reciters. Please note that we are doing our best to stick to the Qarees who the scholars of Ahlus Sunnah have praised for their accuracy in their recitation, as well as their manhaj."), "images/toast/info_icon.png" );
                        }
                    }
                    
                    function onDataLoaded(id, data)
                    {
                        if (id == QueryId.FetchAllRecitations)
                        {
                            var qareeValue = persist.getValueFor("qaree");
                            var n = data.length;
                            var selectedQaree;
                            
                            for (var i = 0; i < n; i++)
                            {
                                var current = data[i];
                                
                                var opt = qareeDef.createObject();
                                opt.text = current.name;
                                opt.description = current.description;
                                opt.value = current.value;
                                
                                if (current.id == 6) {
                                    opt.imageSource = "images/dropdown/ic_reciter_hudhaify.png";
                                } else if (current.id == 7) {
                                    opt.imageSource = "images/dropdown/ic_reciter_husary.png";
                                }
                                
                                reciter.add(opt);
                                
                                if (current.value == qareeValue) {
                                    selectedQaree = opt;
                                }
                            }
                            
                            if (selectedQaree) {
                                selectedOption = selectedQaree;
                            }
                            
                            tutorial.execBelowTitleBar( "translation", qsTr("If you want to show a specific translation for the Qu'ran, choose it here.") );
                            tutorial.execBelowTitleBar( "qaree", qsTr("If you want to use a specific qaree to recite the Qu'ran set it here."), deviceUtils.du(8) );
                            tutorial.execBelowTitleBar( "dloadDir", qsTr("To change the directory where the mushaf pages, ayat images, and recitations are downloaded, set it here."), deviceUtils.du(21), "r" );
                            tutorial.exec( "overlay", qsTr("Sometimes BlackBerry 10's font rules override the arabic rulings of the Qu'ran, and some letters get disconnected. It does not change the meaning however it looks slightly different from the original mushaf text, if you want to prevent this, choose '%1' to display images for the ayats instead of text. Please note that this will have a negative performance impact.").arg(joinDisconnected.text), HorizontalAlignment.Right, VerticalAlignment.Center, 0, 0, 0, deviceUtils.du(8) );
                            tutorial.exec( "keepAwake", qsTr("Use the '%1' feature if you want to keep the device screen lit up when the app is playing the recitation so you can follow along and not have to continually touch the screen.").arg(keepAwake.text), HorizontalAlignment.Right, VerticalAlignment.Center);
                            tutorial.execCentered( "hideBenefits", qsTr("Use the '%1' feature if you want to supress the random quotes that shows up in the start of the app.").arg(hideBenefits.text), "images/menu/ic_copy_from_english.png");
                        }
                    }
                    
                    onCreationCompleted: {
                        helper.fetchAllQarees(reciter, 1);
                    }
                    
                    onSelectedOptionChanged: {
                        infoText.text = qsTr("The verse recitations will be that of %1.").arg(selectedOption.text) + Retranslate.onLanguageChanged
                    }
                    
                    onSelectedValueChanged: {
                        var diff = persist.saveValueFor("qaree", selectedValue);
                        
                        if (diff) {
                            reporter.record("Qaree", selectedValue);
                        }
                    }
                    
                    attachedObjects: [
                        ComponentDefinition
                        {
                            id: qareeDef
                            
                            Option {
                                imageSource: "images/dropdown/ic_reciter.png"
                            }
                        }
                    ]
                }
                
                Container
                {
                    topPadding: 40;
                    
                    attachedObjects: [
                        FilePicker {
                            id: filePicker
                            type : FileType.Music
                            title : qsTr("Select Folder") + Retranslate.onLanguageChanged
                            mode: FilePickerMode.SaverMultiple
                            onFileSelected : {
                                var result = selectedFiles[0]
                                outputLabel.outputDirectory = result
                                var diff = persist.saveValueFor("output", result);
                                
                                if (diff) {
                                    reporter.record("OutputFolder", result);
                                }
                            }
                        }
                    ]
                    
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    Label {
                        property string outputDirectory
                        
                        id: outputLabel
                        text: qsTr("Download directory:\n%1").arg( outputDirectory.substring(15) ) + Retranslate.onLanguageChanged
                        textStyle.fontSize: FontSize.XXSmall
                        textStyle.fontStyle: FontStyle.Italic
                        multiline: true
                        verticalAlignment: VerticalAlignment.Center
                        
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        
                        onCreationCompleted: {
                            var outDir = persist.getValueFor("output");
                            
                            if (!outDir) {
                                outDir = "/accounts/1000/shared/misc/quran10";
                            }
                            
                            filePicker.directories = [outDir, "/accounts/1000/shared/misc/quran10"];
                            outputDirectory = outDir;
                        }
                    }
                    
                    Button
                    {
                        imageSource: "images/dropdown/ic_script.png"
                        text: qsTr("Edit") + Retranslate.onLanguageChanged
                        preferredWidth: 200
                        
                        onClicked: {
                            console.log("UserEvent: EditOutputDir");
                            filePicker.open();
                            
                            reporter.record("EditOutputDir");
                        }
                    }
                    
                    bottomPadding: 50
                }
                
                PersistCheckBox
                {
                    id: joinDisconnected
                    topMargin: 20
                    key: "overlayAyatImages"
                    text: qsTr("Join Disconnected Letters") + Retranslate.onLanguageChanged
                    enabled: mushaf.enableDownloadJoined
                    
                    onValueChanged: {
                        if (checked) {
                            app.checkMissingAyatImages();
                        }
                        
                        reporter.record("JoinDisconnected", checked.toString());
                    }
                    
                    onCheckedChanged: {
                        if (checked) {
                            infoText.text = qsTr("Images will be placed on top of the arabic text to match the rules the Qu'ran was revealed in. Please note that this can cost you ~25 MB of space as well as have a performance impact.") + Retranslate.onLanguageChanged
                        } else {
                            infoText.text = qsTr("The app will render the original Arabic text of the Qu'ran, but the BlackBerry 10 OS may sometimes apply some rules to disconnect some of the letters. This should not change the sounds or the meaning but it should just be a visual difference. This will render the ayats really quickly.") + Retranslate.onLanguageChanged
                        }
                    }
                }
                
                CheckBox
                {
                    id: keepAwake
                    checked: mushaf.keepAwake
                    topMargin: 20
                    text: qsTr("Keep Awake During Recitation") + Retranslate.onLanguageChanged
                    
                    onCheckedChanged: {
                        if (checked) {
                            infoText.text = qsTr("Your device screen will remain awake while the recitation is playing.") + Retranslate.onLanguageChanged
                        } else {
                            infoText.text = qsTr("Your device screen can go to sleep as normal while the recitation is playing.") + Retranslate.onLanguageChanged
                        }
                        
                        mushaf.keepAwake = checked;
                    }
                }
                
                PersistCheckBox
                {
                    id: hideBenefits
                    topMargin: 20
                    key: "hideRandomQuote"
                    text: qsTr("Hide Random Benefits") + Retranslate.onLanguageChanged
                    
                    onValueChanged: {
                        reporter.record("HideBenefits", checked.toString());
                    }
                    
                    onCheckedChanged: {
                        if (checked) {
                            infoText.text = qsTr("A random quote from the Salaf-us-saalih will be displayed every time the app starts up.") + Retranslate.onLanguageChanged
                        } else {
                            infoText.text = qsTr("Random quotes from the Salaf-us-saalih will not be displayed.") + Retranslate.onLanguageChanged
                        }
                    }
                }
                
                PersistCheckBox
                {
                    id: disableSpacing
                    topMargin: 20
                    key: "disableSpacing"
                    text: qsTr("Disable Extra Spacing") + Retranslate.onLanguageChanged
                    
                    onValueChanged: {
                        reporter.record("DisableExtraSpacing", checked.toString());
                    }
                    
                    onCheckedChanged: {
                        if (checked) {
                            infoText.text = qsTr("Extra spacing between the arabic ayat will be disabled. Note that this may cause performance issues.") + Retranslate.onLanguageChanged
                        } else {
                            infoText.text = qsTr("Extra spacing between the arabic text will be added to improve performance.") + Retranslate.onLanguageChanged
                        }
                    }
                }
                
                ImageView
                {
                    topMargin: 0; bottomMargin: 0
                    imageSource: "images/dividers/divider_bio.png"
                    horizontalAlignment: HorizontalAlignment.Center
                }
                
                Label {
                    id: infoText
                    multiline: true
                    textStyle.fontSize: FontSize.XXSmall
                    textStyle.textAlign: TextAlign.Center
                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                    verticalAlignment: VerticalAlignment.Bottom
                    horizontalAlignment: HorizontalAlignment.Center
                }
            }
        }
    }
}