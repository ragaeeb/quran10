import bb.cascades 1.2
import com.canadainc.data 1.0

Page
{
    property variant individualId
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onIndividualIdChanged: {
        
    }
    
    titleBar: TitleBar {}
    
    Container
    {
        layout: DockLayout {}
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill

        ListView
        {
            dataModel: ArrayDataModel {
                id: bios
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    Container
                    {
                        id: bioContainer
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        
                        TextArea
                        {
                            editable: false
                            backgroundVisible: false
                            content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                            input.flags: TextInputFlag.SpellCheckOff
                            text: qsTr("%1\n%2").arg(ListItemData.bio).arg(ListItemData.reference) + Retranslate.onLanguageChanged
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.textAlign: TextAlign.Center
                        }
                        
                        Divider {
                            topMargin: 0; bottomMargin: 0
                            visible: bioContainer.ListItem.indexPath[0] != bioContainer.ListItem.view.dataModel.size()-1
                        }
                    }
                }
            ]
        }
    }
    
    attachedObjects: [
        Delegate
        {
            sourceComponent: ComponentDefinition
            {
                Sheet
                {
                    Page
                    {
                        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
                        
                        titleBar: TitleBar
                        {
                            acceptAction: ActionItem {
                                
                            }
                            
                            dismissAction: ActionItem {
                                
                            }
                        }
                        
                        Container
                        {
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            
                            TextArea
                            {
                                backgroundVisible: false
                                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                                input.flags: TextInputFlag.SpellCheck | TextInputFlag.AutoCapitalization | TextInputFlag.Prediction
                                text: qsTr("%1\n%2").arg(ListItemData.bio).arg(ListItemData.reference) + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Fill
                                
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 0.8
                                }
                            }
                            
                            TextArea
                            {
                                backgroundVisible: false
                                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                                input.flags: TextInputFlag.SpellCheck | TextInputFlag.AutoCapitalization | TextInputFlag.Prediction
                                text: qsTr("%1\n%2").arg(ListItemData.bio).arg(ListItemData.reference) + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Fill
                            }
                        }
                    }
                }
            }
        },
        
        Delegate
        {
            sourceComponent: ComponentDefinition
            {
                Sheet
                {
                    Page
                    {
                        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
                        
                        titleBar: TitleBar
                        {
                            acceptAction: ActionItem {
                            
                            }
                            
                            dismissAction: ActionItem {
                            
                            }
                        }
                        
                        Container
                        {
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            
                            SegmentedControl
                            {
                                horizontalAlignment: HorizontalAlignment.Fill
                                
                                Option {
                                    imageSource: "images/list/ic_dislike.png"
                                    text: qsTr("Jarh") + Retranslate.onLanguageChanged
                                    value: -1
                                }
                                
                                Option {
                                    imageSource: "images/list/ic_like.png"
                                    text: qsTr("Tahdeel") + Retranslate.onLanguageChanged
                                    value: 1
                                }
                            }
                            
                            TextArea
                            {
                                backgroundVisible: false
                                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                                input.flags: TextInputFlag.SpellCheck | TextInputFlag.AutoCapitalization | TextInputFlag.Prediction
                                text: qsTr("%1\n%2").arg(ListItemData.bio).arg(ListItemData.reference) + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Fill
                                
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 0.8
                                }
                            }
                            
                            TextArea
                            {
                                backgroundVisible: false
                                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                                input.flags: TextInputFlag.SpellCheck | TextInputFlag.AutoCapitalization | TextInputFlag.Prediction
                                text: qsTr("%1\n%2").arg(ListItemData.bio).arg(ListItemData.reference) + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Fill
                            }
                        }
                    }
                }
            }
        }
    ]
}