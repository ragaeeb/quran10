import bb.cascades 1.0
import CustomComponent 1.0

BasePage
{
    contentContainer: ScrollView
    {  
    	horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
	    Container
	    {
	        leftPadding: 20
	        topPadding: 20
	        rightPadding: 20
	        bottomPadding: 20
	        
	        SettingPair {
	            topMargin: 20
	            title: qsTr("Hide Data Warning")
	        	toggle.checked: persist.getValueFor("hideDataWarning") == 1
	    
	            toggle.onCheckedChanged: {
	        		persist.saveValueFor("hideDataWarning", checked ? 1 : 0)
	        		
	        		if (checked) {
	        		    infoText.text = qsTr("The warning dialog for downloading will not be shown.") + Retranslate.onLanguageChanged
	                } else {
	        		    infoText.text = qsTr("A warning dialog will be shown next time you attempt to download a recitation to inform you about possible data charges.") + Retranslate.onLanguageChanged
	                }
	            }
	        }
	        
            DropDown {
                title: qsTr("Primary Text") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill

                Option {
                    id: primaryArabic
                    text: qsTr("Arabic") + Retranslate.onLanguageChanged
                    description: qsTr("Original Book") + Retranslate.onLanguageChanged
                    value: "arabic"
                }

                Option {
                    id: primaryTransliteration
                    text: qsTr("Transliteration") + Retranslate.onLanguageChanged
                    description: qsTr("English Transliteration") + Retranslate.onLanguageChanged
                    value: "transliteration"
                }

                onCreationCompleted: {
                    var primary = persist.getValueFor("primary")

                    for (var i = 0; i < options.length; i ++) {
                        if (options[i].value == primary) {
                            options[i].selected = true
                            break;
                        }
                    }
                }

                onSelectedValueChanged: {
                    persist.saveValueFor("primary", selectedValue);
                }

                onSelectedOptionChanged: {
                    if (selectedOption == primaryTransliteration) {
                        infoText.text = qsTr("English transliteration will be displayed in place of Arabic text.") + Retranslate.onLanguageChanged
                    } else {
                        infoText.text = qsTr("Arabic glyphs will be rendered for the primary text.") + Retranslate.onLanguageChanged
                    }
                }
            }

            DropDown {
	            title: qsTr("Translation") + Retranslate.onLanguageChanged
	            horizontalAlignment: HorizontalAlignment.Fill
	            
	            Option {
	                id: none
	                text: qsTr("None") + Retranslate.onLanguageChanged
	                description: qsTr("Do not show any additional languages.") + Retranslate.onLanguageChanged
	                value: ""
	            }
	            
	            Option {
	                text: qsTr("Arabic") + Retranslate.onLanguageChanged
	                description: qsTr("King Fahad Quran Complex") + Retranslate.onLanguageChanged
	                value: "tafsir_arabic_king_fahad"
	            }
	
	            Option {
	                text: qsTr("Bengali") + Retranslate.onLanguageChanged
	                description: qsTr("Zohurul Hoque") + Retranslate.onLanguageChanged
	                value: "bengali"
	            }
	            
	            Option {
	                text: qsTr("Chinese") + Retranslate.onLanguageChanged
	                description: qsTr("Ma Jian (Traditional)") + Retranslate.onLanguageChanged
	                value: "chinese"
	            }
	
	            Option {
	                text: qsTr("English") + Retranslate.onLanguageChanged
	                description: qsTr("Muhammad al-Hilali & Muhsin Khan") + Retranslate.onLanguageChanged
	                value: "english"
	            }
	
	            Option {
	                text: qsTr("French") + Retranslate.onLanguageChanged
	                description: qsTr("Muhammad Hamidullah") + Retranslate.onLanguageChanged
	                value: "french"
	            }
	            
	            Option {
	                text: qsTr("German") + Retranslate.onLanguageChanged
	                description: qsTr("A.S.F. Bubenheim and N. Elyas") + Retranslate.onLanguageChanged
	                value: "german"
	            }
	
	            Option {
	                text: qsTr("Indonesian") + Retranslate.onLanguageChanged
	                description: qsTr("Indonesian Ministry of Religious Affairs") + Retranslate.onLanguageChanged
	                value: "indo"
	            }
	
	            Option {
	                text: qsTr("Malay") + Retranslate.onLanguageChanged
	                description: qsTr("Abdullah Muhammad Basmeih") + Retranslate.onLanguageChanged
	                value: "malay"
	            }
	
	            Option {
	                text: qsTr("Russian") + Retranslate.onLanguageChanged
	                description: qsTr("Elmir Kuliev") + Retranslate.onLanguageChanged
	                value: "russian"
	            }
	            
	            Option {
	                text: qsTr("Spanish") + Retranslate.onLanguageChanged
	                description: qsTr("Julio Cortes") + Retranslate.onLanguageChanged
	                value: "spanish"
	            }
	
	            Option {
	                id: thai
	                text: qsTr("Thai") + Retranslate.onLanguageChanged
	                description: qsTr("Thailand") + Retranslate.onLanguageChanged
	                value: "thai"
	            }
	
	            Option {
	                text: qsTr("Turkish") + Retranslate.onLanguageChanged
	                description: qsTr("Diyanet Vakfi") + Retranslate.onLanguageChanged
	                value: "turkish"
	            }
	
	            Option {
	                text: qsTr("Urdu") + Retranslate.onLanguageChanged
	                description: qsTr("Fateh Muhammad Jalandhry") + Retranslate.onLanguageChanged
	                value: "urdu"
	            }
	            
	            onCreationCompleted: {
	                var translation = persist.getValueFor("translation")
	                
	                for (var i = 0; i < options.length; i++)
	                {
	                    if (options[i].value == translation) {
	                        options[i].selected = true
	                        break;
	                    }
	                }
                }
	            
	            onSelectedValueChanged: {
	                persist.saveValueFor("translation", selectedValue);
	            }
	            
	            onSelectedOptionChanged: {
	                if (selectedOption == none) {
	                    infoText.text = qsTr("No translation will be displayed.") + Retranslate.onLanguageChanged
	                } else {
	                    infoText.text = qsTr("Translation will be provided in %1 by %2.").arg(selectedOption.text).arg(selectedOption.description) + Retranslate.onLanguageChanged
	                }
	            }
	        }

            SettingPair {
                topMargin: 40
                title: qsTr("Repeat Recitation")
                toggle.checked: persist.getValueFor("repeat") == 1

                toggle.onCheckedChanged: {
                    persist.saveValueFor("repeat", checked ? 1 : 0)

                    if (checked) {
                        infoText.text = qsTr("Recitations will keep repeating indefinitely.") + Retranslate.onLanguageChanged
                    } else {
                        infoText.text = qsTr("Recitations will only be played once and stopped.") + Retranslate.onLanguageChanged
                    }
                }
            }

            SettingPair {
                title: qsTr("Follow Recitation")
                toggle.checked: persist.getValueFor("follow") == 1

                toggle.onCheckedChanged: {
                    persist.saveValueFor("follow", checked ? 1 : 0)

                    if (checked) {
                        infoText.text = qsTr("The list will be scrolled to follow the current verse.") + Retranslate.onLanguageChanged
                    } else {
                        infoText.text = qsTr("The list will not scroll to reflect the current verse.") + Retranslate.onLanguageChanged
                    }
                }
            }

            DropDown {
                title: qsTr("Reciter") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill

                Option {
                    text: qsTr("Abdul-Baset Abdel-Samad") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "AbdulSamad_64kbps_QuranExplorer.Com"
                }

                Option {
                    text: qsTr("Abdul-Baset Abdel-Samad") + Retranslate.onLanguageChanged
                    description: qsTr("High Quality") + Retranslate.onLanguageChanged
                    value: "Abdul_Basit_Mujawwad_128kbps"
                }

                Option {
                    text: qsTr("Abdul-Basit Murattal") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Abdul_Basit_Murattal_64kbps"
                }

                Option {
                    text: qsTr("Abdul-Basit Murattal") + Retranslate.onLanguageChanged
                    description: qsTr("High Quality") + Retranslate.onLanguageChanged
                    value: "Abdul_Basit_Murattal_192kbps"
                }

                Option {
                    text: qsTr("Abdullah 'Awwad Al-Juhany") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Abdullaah_3awwaad_Al-Juhaynee_128kbps"
                }

                Option {
                    text: qsTr("Abdullah Basfar") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Abdullah_Basfar_32kbps"
                }

                Option {
                    text: qsTr("Abdullah Basfar") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Abdullah_Basfar_64kbps"
                }

                Option {
                    text: qsTr("Abdullah Basfar") + Retranslate.onLanguageChanged
                    description: qsTr("High Quality") + Retranslate.onLanguageChanged
                    value: "Abdullah_Basfar_192kbps"
                }

                Option {
                    text: qsTr("Abdullah Matroud") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Abdullah_Matroud_128kbps"
                }

                Option {
                    text: qsTr("Abdurrahman As-Sudais") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Abdurrahmaan_As-Sudais_64kbps"
                }

                Option {
                    text: qsTr("Abdurrahman As-Sudais") + Retranslate.onLanguageChanged
                    description: qsTr("High Quality") + Retranslate.onLanguageChanged
                    value: "Abdurrahmaan_As-Sudais_192kbps"
                }

                Option {
                    text: qsTr("Abu Bakr Ash-Shaatree") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Abu_Bakr_Ash-Shaatree_64kbps"
                }

                Option {
                    text: qsTr("Abu Bakr Ash-Shaatree") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Abu_Bakr_Ash-Shaatree_128kbps"
                }

                Option {
                    text: qsTr("Ahmed Neana") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Ahmed_Neana_128kbps"
                }

                Option {
                    text: qsTr("Ahmed Ibn Ali al-Ajamy") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Ahmed_ibn_Ali_al-Ajamy_64kbps_QuranExplorer.Com"
                }

                Option {
                    text: qsTr("Ahmed Ibn Ali al-Ajamy") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net"
                }

                Option {
                    text: qsTr("Ali Abdur-rahman al-Hudhaify") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Hudhaify_64kbps"
                }

                Option {
                    text: qsTr("Ali Abdur-rahman al-Hudhaify") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Hudhaify_128kbps"
                }

                Option {
                    text: qsTr("Hani ar-Rifai") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Hani_Rifai_64kbps"
                }

                Option {
                    text: qsTr("Hani ar-Rifai") + Retranslate.onLanguageChanged
                    description: qsTr("High Quality") + Retranslate.onLanguageChanged
                    value: "Hani_Rifai_192kbps"
                }

                Option {
                    text: qsTr("Ibrahim Akdhar") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Ibrahim_Akhdar_32kbps"
                }

                Option {
                    text: qsTr("Ibrahim Akdhar") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Ibrahim_Akhdar_64kbps"
                }

                Option {
                    text: qsTr("Karim Mansoori") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Karim_Mansoori_40kbps"
                }

                Option {
                    text: qsTr("Khalid Abdullah al-Qahtaanee") + Retranslate.onLanguageChanged
                    description: qsTr("High Quality") + Retranslate.onLanguageChanged
                    value: "Khaalid_Abdullaah_al-Qahtaanee_192kbps"
                }

                Option {
                    text: qsTr("Khalifa Al Tunaiji") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "khalefa_al_tunaiji_64kbps"
                }

                Option {
                    text: qsTr("Maher bin Hamad Al-Mueaqly") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Maher_AlMuaiqly_64kbps"
                }

                Option {
                    text: qsTr("Maher bin Hamad Al-Mueaqly") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Maher_AlMuaiqly_128kbps"
                }

                Option {
                    text: qsTr("Mahmoud Ali Al Banna") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "mahmoud_ali_al_banna_32kbps"
                }

                Option {
                    text: qsTr("Mahmoud Khaleel El-Hosary Mujawwad") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Husary_Mujawwad_64kbps"
                }

                Option {
                    text: qsTr("Mahmoud Khaleel El-Hosary Mujawwad") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Husary_128kbps_Mujawwad"
                }

                Option {
                    text: qsTr("Mishary Rashid Al-Afasy") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Alafasy_64kbps"
                }

                Option {
                    text: qsTr("Mishary Rashid Al-Afasy") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Alafasy_128kbps"
                }

                Option {
                    text: qsTr("Mohammad al Tablaway") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Mohammad_al_Tablaway_64kbps"
                }

                Option {
                    text: qsTr("Mohammad al Tablaway") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Mohammad_al_Tablaway_128kbps"
                }

                Option {
                    text: qsTr("Muhammad Abdulkareem") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Muhammad_AbdulKareem_128kbps"
                }

                Option {
                    text: qsTr("Muhammad Ayyoub") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Muhammad_Ayyoub_32kbps"
                }

                Option {
                    text: qsTr("Muhammad Ayyoub") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Muhammad_Ayyoub_64kbps"
                }

                Option {
                    text: qsTr("Muhammad Ayyoub") + Retranslate.onLanguageChanged
                    description: qsTr("High Quality") + Retranslate.onLanguageChanged
                    value: "Muhammad_Ayyoub_128kbps"
                }

                Option {
                    text: qsTr("Muhammad Jibreel") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Muhammad_Jibreel_64kbps"
                }

                Option {
                    text: qsTr("Muhammad Jibreel") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Muhammad_Jibreel_128kbps"
                }

                Option {
                    text: qsTr("Muhammad Siddiq al-Minshawi") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Menshawi_16kbps"
                }

                Option {
                    text: qsTr("Muhammad Siddiq al-Minshawi") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Menshawi_32kbps"
                }

                Option {
                    text: qsTr("Muhammad Siddiq al-Minshawi") + Retranslate.onLanguageChanged
                    description: qsTr("High Quality") + Retranslate.onLanguageChanged
                    value: "Minshawy_Murattal_128kbps"
                }

                Option {
                    text: qsTr("Muhsin Al-Qasim") + Retranslate.onLanguageChanged
                    description: qsTr("High Quality") + Retranslate.onLanguageChanged
                    value: "Muhsin_Al_Qasim_192kbps"
                }

                Option {
                    text: qsTr("Mustafa Ismail") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Mustafa_Ismail_48kbps"
                }

                Option {
                    text: qsTr("Nasser Alqatami") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Nasser_Alqatami_128kbps"
                }

                Option {
                    text: qsTr("Saad Al-Ghamidi") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Ghamadi_40kbps"
                }

                Option {
                    text: qsTr("Salah Abdulrahman Bukhatir") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Salaah_AbdulRahman_Bukhatir_128kbps"
                }

                Option {
                    text: qsTr("Salah Al-Budair") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Salah_Al_Budair_128kbps"
                }

                Option {
                    text: qsTr("Saud al-Shuraim") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Saood_ash-Shuraym_64kbps"
                }

                Option {
                    text: qsTr("Saud al-Shuraim") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Saood_ash-Shuraym_128kbps"
                }

                Option {
                    text: qsTr("Ustad Shahriar Parhizgar") + Retranslate.onLanguageChanged
                    description: qsTr("Low Quality") + Retranslate.onLanguageChanged
                    value: "Parhizgar_48kbps"
                }

                Option {
                    text: qsTr("Yasser Ad-Dussary") + Retranslate.onLanguageChanged
                    description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
                    value: "Yasser_Ad-Dussary_128kbps"
                }

                onSelectedValueChanged: {
                    persist.saveValueFor("reciter", selectedValue);
                }

                onSelectedOptionChanged: {
                    infoText.text = qsTr("The verse recitations will be that of %1.").arg(selectedOption.text) + Retranslate.onLanguageChanged
                }

                onCreationCompleted: {
                    var reciter = persist.getValueFor("reciter")

                    for (var i = 0; i < options.length; i ++) {
                        if (options[i].value == reciter) {
                            options[i].selected = true
                            break;
                        }
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
	                text: qsTr("Download directory:\n%1").arg(outputDirectory) + Retranslate.onLanguageChanged
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
	            
	            Button {
	                text: qsTr("Edit") + Retranslate.onLanguageChanged
	                preferredWidth: 200
	                
	                onClicked: {
	                    filePicker.open()
	                }
	            }
	            
	            bottomPadding: 50
	        }
            
            SliderPair {
            	labelValue: qsTr("Primary Font Size") + Retranslate.onLanguageChanged
                sliderControl.fromValue: 1
                sliderControl.toValue: 3
                sliderControl.value: persist.getValueFor("primarySize");
                
                onSliderValueChanged: {
                    persist.saveValueFor("primarySize", sliderValue);
                    
                    if (sliderValue == 1) {
                        infoText.text = qsTr("The primary font size will be small");   
                    } else if (sliderValue == 2) {
                        infoText.text = qsTr("The primary font size will be medium");
                    } else {
                        infoText.text = qsTr("The primary font size will be large");
                    }
                }
            }
            
            SliderPair {
                labelValue: qsTr("Translation Font Size") + Retranslate.onLanguageChanged
                sliderControl.fromValue: 1
                sliderControl.toValue: 3
                sliderControl.value: persist.getValueFor("translationSize");
                
                onSliderValueChanged: {
                    persist.saveValueFor("translationSize", sliderValue);
                    
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