import bb.cascades 1.0

ScrollView
{
    id: rootItem
    property variant data: ListItemData
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    scrollViewProperties.pinchToZoomEnabled: true
    scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.OnPinch
    
    onDataChanged: {
        resetViewableArea();
    }
    
    ImageView {
        id: root
        imageSource: ListItemData
        scalingMethod: ScalingMethod.AspectFill
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Fill
        opacity: rootItem.ListItem.active == true ? 0.7 : 1;
        loadEffect: ImageViewLoadEffect.DefaultDeferred
    }
}