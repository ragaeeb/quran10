import bb.cascades 1.2

Slider
{
    id: progress
    verticalAlignment: VerticalAlignment.Center
    
    function onPositionChanged(position) {
        value = position;
    }
    
    function onDurationChanged(duration) {
        toValue = duration;
    }
    
    onTouch: {
        if ( event.isUp() ) {
            player.seek(immediateValue);
        }
    }
    
    layoutProperties: StackLayoutProperties {
        spaceQuota: 1
    }
    
    onCreationCompleted: {
        player.durationChanged.connect(progress.onDurationChanged);
        player.positionChanged.connect(progress.onPositionChanged);
    }
}