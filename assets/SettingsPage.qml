import bb.cascades 1.0
import bb.cascades.pickers 1.0
import com.canadainc.data 1.0

Page
{
    id: settingsPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
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
                        text: qsTr("Indonesian") + Retranslate.onLanguageChanged
                        description: qsTr("Indonesian Ministry of Religious Affairs") + Retranslate.onLanguageChanged
                        value: "indo"
                        imageSource: "images/dropdown/ic_translation.png"
                    }
                    
                    Option {
                        text: qsTr("Malay") + Retranslate.onLanguageChanged
                        description: qsTr("Abdullah Muhammad Basmeih") + Retranslate.onLanguageChanged
                        value: "malay"
                        imageSource: "images/dropdown/ic_translation.png"
                    }
                    
                    Option {
                        text: qsTr("Russian") + Retranslate.onLanguageChanged
                        description: qsTr("Elmir Kuliev") + Retranslate.onLanguageChanged
                        value: "russian"
                        imageSource: "images/dropdown/ic_translation.png"
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
                        description: qsTr("Thailand") + Retranslate.onLanguageChanged
                        value: "thai"
                        imageSource: "images/dropdown/ic_translation.png"
                    }
                    
                    Option {
                        text: qsTr("Turkish") + Retranslate.onLanguageChanged
                        description: qsTr("Diyanet Vakfi") + Retranslate.onLanguageChanged
                        value: "turkish"
                        imageSource: "images/dropdown/ic_translation.png"
                    }
                    
                    Option {
                        text: qsTr("Urdu") + Retranslate.onLanguageChanged
                        description: qsTr("Fateh Muhammad Jalandhry") + Retranslate.onLanguageChanged
                        value: "urdu"
                        imageSource: "images/dropdown/ic_translation.png"
                    }
                    
                    onSelectedOptionChanged: {
                        if (selectedOption == none) {
                            infoText.text = qsTr("No translation will be displayed.") + Retranslate.onLanguageChanged
                        } else if (selectedOption == english) {
                            infoText.text = qsTr("Translation will be provided in %1 by %2. Please see why this is the only English translation we support:\nhttps://www.youtube.com/watch?v=BDY8i9VQeZM").arg(selectedOption.text).arg(selectedOption.description) + Retranslate.onLanguageChanged
                            infoText.content.flags = TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff;
                        } else {
                            infoText.text = qsTr("Translation will be provided in %1 by %2.").arg(selectedOption.text).arg(selectedOption.description) + Retranslate.onLanguageChanged
                        }
                    }
                }
                
                DropDown
                {
                    id: reciter
                    title: qsTr("Reciter") + Retranslate.onLanguageChanged
                    
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
                        }
                    }
                    
                    onCreationCompleted: {
                        helper.fetchAllQarees(reciter, 1);
                    }
                    
                    onSelectedOptionChanged: {
                        infoText.text = qsTr("The verse recitations will be that of %1.").arg(selectedOption.text) + Retranslate.onLanguageChanged
                    }
                    
                    onSelectedValueChanged: {
                        persist.saveValueFor("qaree", selectedValue);
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
                                persist.saveValueFor("output", result, false);
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
                            filePicker.open()
                        }
                    }
                    
                    bottomPadding: 50
                }
                
                PersistCheckBox
                {
                    topMargin: 20
                    key: "overlayAyatImages"
                    text: qsTr("Join Disconnected Letters") + Retranslate.onLanguageChanged
                    enabled: mushaf.enableDownloadJoined
                    
                    onValueChanged: {
                        if (checked) {
                            app.checkMissingAyatImages();
                        }
                    }
                    
                    onCheckedChanged: {
                        if (checked) {
                            infoText.text = qsTr("Images will be placed on top of the arabic text to match the rules the Qu'ran was revealed in. Please note that this can cost you ~25 MB of space as well as have a performance impact.") + Retranslate.onLanguageChanged
                        } else {
                            infoText.text = qsTr("The app will render the original Arabic text of the Qu'ran, but the BlackBerry 10 OS may sometimes apply some rules to disconnect some of the letters. This should not change the sounds or the meaning but it should just be a visual difference. This will render the ayats really quickly.") + Retranslate.onLanguageChanged
                        }
                    }
                }
                
                PersistCheckBox
                {
                    topMargin: 20
                    key: "keepAwakeDuringPlay"
                    text: qsTr("Keep Awake During Recitation") + Retranslate.onLanguageChanged
                    
                    onCheckedChanged: {
                        if (checked) {
                            infoText.text = qsTr("Your device screen will remain awake while the recitation is playing.") + Retranslate.onLanguageChanged
                        } else {
                            infoText.text = qsTr("Your device screen can go to sleep as normal while the recitation is playing.") + Retranslate.onLanguageChanged
                        }
                    }
                }
                
                ProgressIndicator
                {
                    id: progressIndicator
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    value: 0
                    fromValue: 0
                    toValue: 100
                    opacity: value == 0 ? 0 : value/100
                    state: ProgressIndicatorState.Progress
                    topMargin: 0; bottomMargin: 0; leftMargin: 0; rightMargin: 0;
                    
                    function onNetworkProgressChanged(cookie, current, total)
                    {
                        value = current;
                        toValue = total;
                        
                        infoText.text = qsTr("Uploading %1/%2...").arg( current.toString() ).arg( total.toString() );
                    }
                    
                    function onCompressed()
                    {
                        infoText.text = qsTr("Uploading...");
                        busy.delegateActive = false;
                    }
                    
                    function onCompressProgress(current, total)
                    {
                        value = current;
                        toValue = total;

                        infoText.text = qsTr("Compressing %1/%2...").arg( current.toString() ).arg( total.toString() );
                    }
                    
                    function onCompressing()
                    {
                        infoText.text = qsTr("Compressing...");
                        infoText.content.flags = TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff;
                        busy.delegateActive = true;
                    }
                    
                    onCreationCompleted: {
                        admin.uploadProgress.connect(onNetworkProgressChanged);
                        admin.compressing.connect(onCompressing);
                        admin.compressed.connect(onCompressed);
                        admin.compressProgress.connect(onCompressProgress);
                    }
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
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/uploading_local.png"
        }
    }
    
    onCreationCompleted: {
        admin.initPage(settingsPage);
    }
}