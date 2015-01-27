import bb.cascades 1.2

Container
{
    topPadding: 10; bottomPadding: 10; leftPadding: 10; rightPadding: 10
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    property bool downloaded: false
    property bool played: false
    
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    ImageButton
    {
        id: actionButton
        pressedImageSource: defaultImageSource
        verticalAlignment: VerticalAlignment.Center
        
        function updateImage()
        {
            defaultImageSource = player.playing && played ? "images/menu/ic_pause.png" : "images/menu/ic_play.png";
            rotator.play();
        }
        
        function onError(message) {
            defaultImageSource = "images/menu/ic_play.png";
        }
        
        onClicked: {
            console.log("UserEvent: DownloadPlayButtonClicked");
            
            if (!downloaded) {
                app.progress.connect(progress.onNetworkProgressChanged);
                app.download(root.collection, root.hadithNumber);
            } else {
                if (!played) {
                    player.durationChanged.connect(progress.onDurationChanged);
                    player.positionChanged.connect(progress.onPositionChanged);
                    player.playingChanged.connect(updateImage);
                    player.activeChanged.connect(updateImage);
                    player.error.connect(onError);
                    app.play(root.collection, root.hadithNumber);
                    played = true;
                } else {
                    player.togglePlayback();
                }
            }
        }
        
        animations: [
            RotateTransition {
                id: rotator
                fromAngleZ: 0
                toAngleZ: 360
                delay: 500
                duration: 1000
                easingCurve: StockCurve.QuinticOut
            }
        ]
    }
    
    Slider
    {
        id: progress
        enabled: downloaded
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
        
        function onNetworkProgressChanged(cookie, current, total)
        {
            if (cookie.hadithNumber == root.hadithNumber && cookie.collection == root.collection)
            {
                value = current;
                toValue = total;
            }
        }
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
    }
    
    function updateState()
    {
        downloaded = app.isDownloaded(root.collection, root.hadithNumber);
        
        if (downloaded) {
            actionButton.defaultImageSource = player.active && played ? "images/menu/ic_pause.png" : "images/menu/ic_play.png";
        } else {
            actionButton.defaultImageSource = "images/audio/download.png";
        }
        
        rotator.play();
    }
    
    function onAudioAvailable(collection, hadithNumber)
    {
        if (collection == root.collection && hadithNumber == root.hadithNumber) {
            updateState();
        }
    }
    
    onCreationCompleted: {
        updateState();
        app.audioAvailable.connect(onAudioAvailable);
    }
}