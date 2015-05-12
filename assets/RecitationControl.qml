import bb.cascades 1.3
import com.canadainc.data 1.0

Container
{
    topPadding: 10; bottomPadding: 10; leftPadding: 10; rightPadding: 10
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    property bool downloaded: false
    property bool played: false
    property alias playerRef: player

    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }

    ImageButton
    {
        id: actionButton
        defaultImageSource: player.playing && played ? "images/menu/ic_pause.png" : "images/menu/ic_play.png";
        pressedImageSource: defaultImageSource
        verticalAlignment: VerticalAlignment.Center
        
        onCreationCompleted: {
            player.durationChanged.connect(progress.onDurationChanged);
            player.positionChanged.connect(progress.onPositionChanged);
            
            rotator.play();
        }
        
        onClicked: {
            console.log("UserEvent: DownloadPlayButtonClicked");
            
            if (!played) {
                recitation.downloadAndPlay(root.surahId, root.verseId);
                played = true;
                reporter.record("AyatDownloadPlay", root.surahId+":"+root.verseId);
            } else {
                player.togglePlayback();
                reporter.record("AyatPlayPause");
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
                
                onCreationCompleted: {
                    tutorial.execBelowTitleBar( "recitePlay", qsTr("Tap on the Play button to begin playback of this ayat or download it if it is not yet downloaded."), 0, "l" );
                }
                
                onEnded: {
                    tutorial.execBelowTitleBar( "reciteSeek", qsTr("Once playback begins, you can use the seek bar to rewind or forward the recitation."), 0, "l", "r" );
                }
            }
        ]
    }
    
    Slider
    {
        id: progress
        enabled: player.playing
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
    }
    
    function onReady(uri) {
        player.play(uri);
        rotator.play();
    }
    
    onCreationCompleted: {
        recitation.readyToPlay.connect(onReady);
    }
    
    attachedObjects: [
        LazyMediaPlayer
        {
            id: player
            repeat: true
            
            onError: {
                console.log(message);
                persist.showToast( message, "asset:///images/toast/yellow_delete.png" );
                
                reporter.record("AyatPlayError", message);
            }
        }
    ]
}