import bb.cascades 1.0
import bb.cascades.pickers 1.0

Page
{
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    ScrollView
    {  
    	horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
	    Container
	    {
	        leftPadding: 20
	        topPadding: 20
	        rightPadding: 20
	        bottomPadding: 20
	        horizontalAlignment: HorizontalAlignment.Fill
	        verticalAlignment: VerticalAlignment.Fill
	        
            PersistDropDown
            {
                key: "primary"
                title: qsTr("Primary Text") + Retranslate.onLanguageChanged

                Option {
                    id: primaryUthmani
                    text: qsTr("Uthmani Script") + Retranslate.onLanguageChanged
                    description: qsTr("An old-fashion Arabic script used by the third Caliph, Uthman, to produce the first standard quran manuscript.") + Retranslate.onLanguageChanged
                    value: "arabic_uthmani"
                    imageSource: "images/dropdown/ic_script.png"
                }

                Option {
                    id: primaryTransliteration
                    text: qsTr("Transliteration") + Retranslate.onLanguageChanged
                    description: qsTr("English Transliteration") + Retranslate.onLanguageChanged
                    value: "transliteration"
                    imageSource: "images/dropdown/ic_script.png"
                }

                onSelectedOptionChanged: {
                    if (selectedOption == primaryTransliteration) {
                        infoText.text = qsTr("English transliteration will be displayed in place of Arabic text.") + Retranslate.onLanguageChanged
                    } else if (selectedOption == primaryImlaei) {
                        infoText.text = qsTr("Modern Arabic glyphs will be rendered for the primary text.") + Retranslate.onLanguageChanged
                    } else {
                        infoText.text = qsTr("Old-fashioned Arabic glyphs will be rendered for the primary text.") + Retranslate.onLanguageChanged
                    }
                }
            }

            PersistDropDown
            {
	            title: qsTr("Translation") + Retranslate.onLanguageChanged
	            horizontalAlignment: HorizontalAlignment.Fill
	            key: "translation"
	            
	            Option {
	                id: none
	                text: qsTr("None") + Retranslate.onLanguageChanged
	                description: qsTr("Do not show any additional languages.") + Retranslate.onLanguageChanged
	                value: ""
	                imageSource: "images/dropdown/ic_delete.png"
	            }
	            
	            Option {
	                text: qsTr("Arabic") + Retranslate.onLanguageChanged
	                description: qsTr("King Fahad Quran Complex") + Retranslate.onLanguageChanged
	                value: "tafsir_arabic_king_fahad"
                    imageSource: "images/dropdown/ic_translation.png"
	            }
	
	            Option {
	                text: qsTr("Bengali") + Retranslate.onLanguageChanged
	                description: qsTr("Zohurul Hoque") + Retranslate.onLanguageChanged
	                value: "bengali"
                    imageSource: "images/dropdown/ic_translation.png"
	            }
	            
	            Option {
	                text: qsTr("Chinese") + Retranslate.onLanguageChanged
	                description: qsTr("Ma Jian (Traditional)") + Retranslate.onLanguageChanged
	                value: "chinese"
                    imageSource: "images/dropdown/ic_translation.png"
	            }
	
	            Option {
	                text: qsTr("English") + Retranslate.onLanguageChanged
	                description: qsTr("Muhammad al-Hilali & Muhsin Khan") + Retranslate.onLanguageChanged
	                value: "english"
                    imageSource: "images/dropdown/ic_translation.png"
	            }
	
	            Option {
	                text: qsTr("French") + Retranslate.onLanguageChanged
	                description: qsTr("Muhammad Hamidullah") + Retranslate.onLanguageChanged
	                value: "french"
                    imageSource: "images/dropdown/ic_translation.png"
	            }
	            
	            Option {
	                text: qsTr("German") + Retranslate.onLanguageChanged
	                description: qsTr("A.S.F. Bubenheim and N. Elyas") + Retranslate.onLanguageChanged
	                value: "german"
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
	                } else {
	                    infoText.text = qsTr("Translation will be provided in %1 by %2.").arg(selectedOption.text).arg(selectedOption.description) + Retranslate.onLanguageChanged
	                }
	            }
	        }
            
            ReciterDropDown
            {
                onSelectedOptionChanged: {
                    infoText.text = qsTr("The verse recitations will be that of %1.").arg(selectedOption.text) + Retranslate.onLanguageChanged
                }
            }

            PersistCheckBox
            {
                topMargin: 20
                key: "repeat"
                text: qsTr("Repeat Recitation") + Retranslate.onLanguageChanged
                
                onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("Recitations will keep repeating indefinitely.") + Retranslate.onLanguageChanged
                    } else {
                        infoText.text = qsTr("Recitations will only be played once and stopped.") + Retranslate.onLanguageChanged
                    }
                }
            }

            PersistCheckBox
            {
                topMargin: 20
                text: qsTr("Follow Recitation") + Retranslate.onLanguageChanged
                key: "follow"

                onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("The list will be scrolled to follow the current verse.") + Retranslate.onLanguageChanged
                    } else {
                        infoText.text = qsTr("The list will not scroll to reflect the current verse.") + Retranslate.onLanguageChanged
                    }
                }
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
							persist.saveValueFor("output", result)
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
			            var outDir = persist.getValueFor("output")
			            filePicker.directories = [outDir, "/accounts/1000/shared/quran10"]
			            outputDirectory = outDir
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
            
            SliderPair
            {
                labelValue: qsTr("Translation Font Size") + Retranslate.onLanguageChanged
                from: 1
                to: 3
                key: "translationSize"
                
                onSliderValueChanged: {
                    if (sliderValue == 1) {
                        infoText.text = qsTr("The translation font size will be small");   
                    } else if (sliderValue == 2) {
                        infoText.text = qsTr("The translation font size will be medium");
                    } else {
                        infoText.text = qsTr("The translation font size will be large");
                    }
                }
            }
	        
	        Label {
	            id: infoText
	            multiline: true
	            textStyle.fontSize: FontSize.XXSmall
	            textStyle.textAlign: TextAlign.Center
	            verticalAlignment: VerticalAlignment.Bottom
	            horizontalAlignment: HorizontalAlignment.Center
	        }
	    }
    }
}