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
	            title: qsTr("Animations")
	        	toggle.checked: persist.getValueFor("animations") == 1
	    
	            toggle.onCheckedChanged: {
	        		persist.saveValueFor("animations", checked ? 1 : 0)
	        		
	        		if (checked) {
	        		    infoText.text = qsTr("Controls will be animated whenever they are loaded.") + Retranslate.onLanguageChanged
	                } else {
	        		    infoText.text = qsTr("Controls will be snapped into position without animations.") + Retranslate.onLanguageChanged
	                }
	            }
	        }
	        
	        DropDown {
	            title: qsTr("Primary Language") + Retranslate.onLanguageChanged
	            horizontalAlignment: HorizontalAlignment.Fill
	
	            Option {
	                id: arabic
	                text: qsTr("Arabic") + Retranslate.onLanguageChanged
	                description: qsTr("Show arabic glyphs.") + Retranslate.onLanguageChanged
	                value: "arabic"
	                selected: persist.getValueFor("primaryLanguage") == value
	            }
	
	            Option {
	                id: english_transliteration
	                text: qsTr("Transliteration") + Retranslate.onLanguageChanged
	                description: qsTr("Transliteration in English") + Retranslate.onLanguageChanged
	                value: "english_transliteration"
	                selected: persist.getValueFor("primaryLanguage") == value
	            }
	            
	            onSelectedValueChanged: {
	                persist.saveValueFor("primaryLanguage", selectedValue);
	            }
	            
	            onSelectedOptionChanged: {
	                if (selectedOption == arabic) {
	                    infoText.text = qsTr("Arabic glyphs will be shown for the chapter verses.") + Retranslate.onLanguageChanged
	                } else if (selectedOption == english_transliteration) {
	                    infoText.text = qsTr("Transliteration will be shown using the English alphabet.") + Retranslate.onLanguageChanged
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
	                selected: persist.getValueFor("translation") == value
	            }
	
	            Option {
	                id: bengali
	                text: qsTr("Bengali") + Retranslate.onLanguageChanged
	                description: qsTr("Ataul Haque") + Retranslate.onLanguageChanged
	                value: "bengali"
	                selected: persist.getValueFor("translation") == value
	            }
	
	            Option {
	                id: english_pickthall
	                text: qsTr("English") + Retranslate.onLanguageChanged
	                description: qsTr("Pickthall") + Retranslate.onLanguageChanged
	                value: "english_pickthall"
	                selected: persist.getValueFor("translation") == value
	            }
	
	            Option {
	                id: english_shakir
	                text: qsTr("English") + Retranslate.onLanguageChanged
	                description: qsTr("Shakir") + Retranslate.onLanguageChanged
	                value: "english_shakir"
	                selected: persist.getValueFor("translation") == value
	            }
	
	            Option {
	                id: french
	                text: qsTr("French") + Retranslate.onLanguageChanged
	                description: qsTr("French") + Retranslate.onLanguageChanged
	                value: "french"
	                selected: persist.getValueFor("translation") == value
	            }
	
	            Option {
	                id: indonesian_bahasa
	                text: qsTr("Indonesian") + Retranslate.onLanguageChanged
	                description: qsTr("Bahasa Indonesia") + Retranslate.onLanguageChanged
	                value: "indonesian_bahasa"
	                selected: persist.getValueFor("translation") == value
	            }
	
	            Option {
	                id: malay
	                text: qsTr("Malay") + Retranslate.onLanguageChanged
	                description: qsTr("Malaysian") + Retranslate.onLanguageChanged
	                value: "malay"
	                selected: persist.getValueFor("translation") == value
	            }
	
	            Option {
	                id: somali_al_barwani
	                text: qsTr("Somali") + Retranslate.onLanguageChanged
	                description: qsTr("Al Barwani") + Retranslate.onLanguageChanged
	                value: "somali_al_barwani"
	                selected: persist.getValueFor("translation") == value
	            }
	
	            Option {
	                id: thai
	                text: qsTr("Thai") + Retranslate.onLanguageChanged
	                description: qsTr("Thailand") + Retranslate.onLanguageChanged
	                value: "thai"
	                selected: persist.getValueFor("translation") == value
	            }
	
	            Option {
	                id: turkish_ali_bulac
	                text: qsTr("Turkish") + Retranslate.onLanguageChanged
	                description: qsTr("Ali Bulac") + Retranslate.onLanguageChanged
	                value: "turkish_ali_bulac"
	                selected: persist.getValueFor("translation") == value
	            }
	
	            Option {
	                id: urdu_ahmed_ali
	                text: qsTr("Urdu") + Retranslate.onLanguageChanged
	                description: qsTr("Ahmed Ali") + Retranslate.onLanguageChanged
	                value: "urdu_ahmed_ali"
	                selected: persist.getValueFor("translation") == value
	            }
	
	            onSelectedValueChanged: {
	                persist.saveValueFor("translation", selectedValue);
	            }
	            
	            onSelectedOptionChanged: {
	                if (selectedOption == none) {
	                    infoText.text = qsTr("No translation will be displayed.") + Retranslate.onLanguageChanged
	                } else if (selectedOption == bengali) {
	                    infoText.text = qsTr("Translation will be provided in Bengali.") + Retranslate.onLanguageChanged
	                } else if (selectedOption == english_pickthall) {
	                    infoText.text = qsTr("Translation will be provided in English by Marmaduke Pickthall.") + Retranslate.onLanguageChanged
	                } else if (selectedOption == english_shakir) {
	                    infoText.text = qsTr("Translation will be provided in English by Muhammad Habib Shakir.") + Retranslate.onLanguageChanged
	                } else if (selectedOption == french) {
	                    infoText.text = qsTr("Translation will be provided in French.") + Retranslate.onLanguageChanged
	                } else if (selectedOption == indonesian_bahasa) {
	                    infoText.text = qsTr("Translation will be provided in Indonesian Bahasa.") + Retranslate.onLanguageChanged
	                } else if (selectedOption == malay) {
	                    infoText.text = qsTr("Translation will be provided in Malay.") + Retranslate.onLanguageChanged
	                } else if (selectedOption == somali_al_barwani) {
	                    infoText.text = qsTr("Translation will be provided in Somali by Al Barwani.") + Retranslate.onLanguageChanged
	                } else if (selectedOption == thai) {
	                    infoText.text = qsTr("Translation will be provided in Thai.") + Retranslate.onLanguageChanged
	                } else if (selectedOption == turkish_ali_bulac) {
	                    infoText.text = qsTr("Translation will be provided in Turkish by Ali Bulac.") + Retranslate.onLanguageChanged
	                } else if (selectedOption == urdu_ahmed_ali) {
	                    infoText.text = qsTr("Translation will be provided in Urdu by Ahmed Ali.") + Retranslate.onLanguageChanged
	                }
	            }
	        }
	        
	        Container
	        {
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
	        }
	        
	        DropDown {
	            title: qsTr("Reciter") + Retranslate.onLanguageChanged
	            horizontalAlignment: HorizontalAlignment.Fill
	
	            Option {
	                text: qsTr("Abdul-Baset Abdel-Samad") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "AbdulSamad_64kbps_QuranExplorer.Com"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Abdul-Baset Abdel-Samad") + Retranslate.onLanguageChanged
	                description: qsTr("High Quality") + Retranslate.onLanguageChanged
	                value: "Abdul_Basit_Mujawwad_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Abdul-Basit Murattal") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Abdul_Basit_Murattal_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Abdul-Basit Murattal") + Retranslate.onLanguageChanged
	                description: qsTr("High Quality") + Retranslate.onLanguageChanged
	                value: "Abdul_Basit_Murattal_192kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Abdullah 'Awwad Al-Juhany") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Abdullaah_3awwaad_Al-Juhaynee_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Abdullah Basfar") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Abdullah_Basfar_32kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Abdullah Basfar") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Abdullah_Basfar_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Abdullah Basfar") + Retranslate.onLanguageChanged
	                description: qsTr("High Quality") + Retranslate.onLanguageChanged
	                value: "Abdullah_Basfar_192kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Abdullah Matroud") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Abdullah_Matroud_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Abdurrahman As-Sudais") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Abdurrahmaan_As-Sudais_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Abdurrahman As-Sudais") + Retranslate.onLanguageChanged
	                description: qsTr("High Quality") + Retranslate.onLanguageChanged
	                value: "Abdurrahmaan_As-Sudais_192kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Abu Bakr Ash-Shaatree") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Abu_Bakr_Ash-Shaatree_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Abu Bakr Ash-Shaatree") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Abu_Bakr_Ash-Shaatree_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Ahmed Neana") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Ahmed_Neana_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Ahmed Ibn Ali al-Ajamy") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Ahmed_ibn_Ali_al-Ajamy_64kbps_QuranExplorer.Com"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Ahmed Ibn Ali al-Ajamy") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Ahmed_ibn_Ali_al-Ajamy_128kbps_QuranExplorer.Com"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Ali Abdur-rahman al-Hudhaify") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Hudhaify_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Ali Abdur-rahman al-Hudhaify") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Hudhaify_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Hani ar-Rifai") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Hani_Rifai_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Hani ar-Rifai") + Retranslate.onLanguageChanged
	                description: qsTr("High Quality") + Retranslate.onLanguageChanged
	                value: "Hani_Rifai_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Ibrahim Akdhar") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Ibrahim_Akhdar_32kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Ibrahim Akdhar") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Ibrahim_Akhdar_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }

	            Option {
	                text: qsTr("Karim Mansoori") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Karim_Mansoori_40kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Khalid Abdullah al-Qahtaanee") + Retranslate.onLanguageChanged
	                description: qsTr("High Quality") + Retranslate.onLanguageChanged
	                value: "Khaalid_Abdullaah_al-Qahtaanee_192kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Khalifa Al Tunaiji") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "khalefa_al_tunaiji_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Maher bin Hamad Al-Mueaqly") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Maher_AlMuaiqly_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Maher bin Hamad Al-Mueaqly") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Maher_AlMuaiqly_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Mahmoud Ali Al Banna") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "mahmoud_ali_al_banna_32kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Mahmoud Khaleel El-Hosary Mujawwad") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Husary_Mujawwad_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Mahmoud Khaleel El-Hosary Mujawwad") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Husary_128kbps_Mujawwad"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Mishary Rashid Al-Afasy") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Alafasy_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Mishary Rashid Al-Afasy") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Alafasy_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Mohammad al Tablaway") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Mohammad_al_Tablaway_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Mohammad al Tablaway") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Mohammad_al_Tablaway_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Muhammad Abdulkareem") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Muhammad_AbdulKareem_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Muhammad Ayyoub") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Muhammad_Ayyoub_32kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Muhammad Ayyoub") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Muhammad_Ayyoub_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Muhammad Ayyoub") + Retranslate.onLanguageChanged
	                description: qsTr("High Quality") + Retranslate.onLanguageChanged
	                value: "Muhammad_Ayyoub_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Muhammad Jibreel") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Muhammad_Jibreel_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Muhammad Jibreel") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Muhammad_Jibreel_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Muhammad Siddiq al-Minshawi") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Menshawi_16kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Muhammad Siddiq al-Minshawi") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Menshawi_32kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Muhammad Siddiq al-Minshawi") + Retranslate.onLanguageChanged
	                description: qsTr("High Quality") + Retranslate.onLanguageChanged
	                value: "Minshawy_Murattal_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Muhsin Al-Qasim") + Retranslate.onLanguageChanged
	                description: qsTr("High Quality") + Retranslate.onLanguageChanged
	                value: "Muhsin_Al_Qasim_192kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Mustafa Ismail") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Mustafa_Ismail_48kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Nasser Alqatami") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Nasser_Alqatami_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Saad Al-Ghamidi") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Ghamadi_40kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Salah Abdulrahman Bukhatir") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Salaah_AbdulRahman_Bukhatir_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Salah Al-Budair") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Salah_Al_Budair_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Saud al-Shuraim") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Saood_ash-Shuraym_64kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Saud al-Shuraim") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Saood_ash-Shuraym_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Ustad Shahriar Parhizgar") + Retranslate.onLanguageChanged
	                description: qsTr("Low Quality") + Retranslate.onLanguageChanged
	                value: "Parhizgar_48kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            Option {
	                text: qsTr("Yasser Ad-Dussary") + Retranslate.onLanguageChanged
	                description: qsTr("Medium Quality") + Retranslate.onLanguageChanged
	                value: "Yasser_Ad-Dussary_128kbps"
	                selected: persist.getValueFor("reciter") == value
	            }
	            
	            onSelectedValueChanged: {
	                persist.saveValueFor("reciter", selectedValue);
	            }
	            
	            onSelectedOptionChanged: {
	                infoText.text = qsTr("The verse recitations will be that of %1.").arg(selectedOption.text) + Retranslate.onLanguageChanged
	            }
	        }
	        
	        SettingPair {
	            topMargin: 20
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