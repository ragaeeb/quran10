import bb.cascades 1.2
import com.canadainc.data 1.0

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
        
        onCreationCompleted: {
            player.durationChanged.connect(progress.onDurationChanged);
            player.positionChanged.connect(progress.onPositionChanged);
            player.playingChanged.connect(updateImage);
            player.activeChanged.connect(updateImage);
            player.error.connect(onError);
        }
        
        onClicked: {
            console.log("UserEvent: DownloadPlayButtonClicked");
            
            if (!downloaded) {
                queue.downloadProgress.connect(progress.onNetworkProgressChanged);
                recitation.downloadAndPlay(root.surahId, root.verseId);
            } else {
                if (!played) {
                    recitation.downloadAndPlay(root.surahId, root.verseId);
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
            if (cookie.chapter == root.surahId && cookie.verse == root.verseId)
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
        downloaded = recitation.isDownloaded(root.surahId, root.verseId);
        
        if (downloaded) {
            actionButton.defaultImageSource = player.active && played ? "images/menu/ic_pause.png" : "images/menu/ic_play.png";
        } else {
            actionButton.defaultImageSource = "images/menu/ic_download_mushaf.png";
        }
        
        rotator.play();
    }
    
    function onReady(uri)
    {
        player.play(uri);
        updateState();
    }
    
    onCreationCompleted: {
        updateState();
        recitation.readyToPlay.connect(onReady);
    }
    
    attachedObjects: [
        LazyMediaPlayer {
            id: player
            repeat: true
        }
    ]
}