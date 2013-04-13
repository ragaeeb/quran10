import bb.cascades 1.0

BasePage
{
    contentContainer: Container
    {
        leftPadding: 20
        topPadding: 20
        rightPadding: 20
        bottomPadding: 20
        
        SettingPair {
            topMargin: 20
            title: qsTr("Animations")
        	toggle.checked: app.getValueFor("animations") == 1
    
            toggle.onCheckedChanged: {
        		app.saveValueFor("animations", checked ? 1 : 0)
        		
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
                selected: app.getValueFor("primaryLanguage") == value
            }

            Option {
                id: english_transliteration
                text: qsTr("Transliteration") + Retranslate.onLanguageChanged
                description: qsTr("Transliteration in English") + Retranslate.onLanguageChanged
                value: "english_transliteration"
                selected: app.getValueFor("primaryLanguage") == value
            }
            
            onSelectedValueChanged: {
                app.saveValueFor("primaryLanguage", selectedValue);
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
                selected: app.getValueFor("translation") == value
            }

            Option {
                id: bengali
                text: qsTr("Bengali") + Retranslate.onLanguageChanged
                description: qsTr("Ataul Haque") + Retranslate.onLanguageChanged
                value: "bengali"
                selected: app.getValueFor("translation") == value
            }

            Option {
                id: english_pickthall
                text: qsTr("English") + Retranslate.onLanguageChanged
                description: qsTr("Pickthall") + Retranslate.onLanguageChanged
                value: "english_pickthall"
                selected: app.getValueFor("translation") == value
            }

            Option {
                id: english_shakir
                text: qsTr("English") + Retranslate.onLanguageChanged
                description: qsTr("Shakir") + Retranslate.onLanguageChanged
                value: "english_shakir"
                selected: app.getValueFor("translation") == value
            }

            Option {
                id: french
                text: qsTr("French") + Retranslate.onLanguageChanged
                description: qsTr("French") + Retranslate.onLanguageChanged
                value: "french"
                selected: app.getValueFor("translation") == value
            }

            Option {
                id: indonesian_bahasa
                text: qsTr("Indonesian") + Retranslate.onLanguageChanged
                description: qsTr("Bahasa Indonesia") + Retranslate.onLanguageChanged
                value: "indonesian_bahasa"
                selected: app.getValueFor("translation") == value
            }

            Option {
                id: malay
                text: qsTr("Malay") + Retranslate.onLanguageChanged
                description: qsTr("Malaysian") + Retranslate.onLanguageChanged
                value: "malay"
                selected: app.getValueFor("translation") == value
            }

            Option {
                id: somali_al_barwani
                text: qsTr("Somali") + Retranslate.onLanguageChanged
                description: qsTr("Al Barwani") + Retranslate.onLanguageChanged
                value: "somali_al_barwani"
                selected: app.getValueFor("translation") == value
            }

            Option {
                id: thai
                text: qsTr("Thai") + Retranslate.onLanguageChanged
                description: qsTr("Thailand") + Retranslate.onLanguageChanged
                value: "thai"
                selected: app.getValueFor("translation") == value
            }

            Option {
                id: turkish_ali_bulac
                text: qsTr("Turkish") + Retranslate.onLanguageChanged
                description: qsTr("Ali Bulac") + Retranslate.onLanguageChanged
                value: "turkish_ali_bulac"
                selected: app.getValueFor("translation") == value
            }

            Option {
                id: urdu_ahmed_ali
                text: qsTr("Urdu") + Retranslate.onLanguageChanged
                description: qsTr("Ahmed Ali") + Retranslate.onLanguageChanged
                value: "urdu_ahmed_ali"
                selected: app.getValueFor("translation") == value
            }

            onSelectedValueChanged: {
                app.saveValueFor("translation", selectedValue);
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