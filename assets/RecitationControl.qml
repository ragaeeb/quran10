import bb.cascades 1.2
import com.canadainc.data 1.0

Container
{
    topPadding: 10; bottomPadding: 10; leftPadding: 10; rightPadding: 10
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    property bool played: false
    property bool tajweedPlayed: false
    property bool showTajweed: recitation.tajweedAvailable(root.surahId, root.verseId)
    
    function cleanUp()
    {
        if (played || tajweedPlayed) {
            player.stop();
        }

        recitation.readyToPlay.disconnect(onReady);
    }

    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }

    ImageButton
    {
        id: actionButton
        defaultImageSource: player.playing && played ? "images/menu/ic_pause.png" : "images/menu/ic_play.png";
        pressedImageSource: defaultImageSource
        verticalAlignment: VerticalAlignment.Center
        preferredHeight: 64
        preferredWidth: 64
        
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
        
        onCreationCompleted: {
            player.durationChanged.connect(progress.onDurationChanged);
            player.positionChanged.connect(progress.onPositionChanged);
            
            rotator.play();
        }
    }
    
    ControlDelegate
    {
        id: tajweedDelegate
        delegateActive: showTajweed
        visible: delegateActive
        
        sourceComponent: ComponentDefinition
        {
            ImageButton
            {
                defaultImageSource: player.playing && tajweedPlayed ? "images/menu/ic_pause.png" : "images/menu/ic_play.png";
                pressedImageSource: defaultImageSource
                verticalAlignment: VerticalAlignment.Center
                preferredHeight: 64
                preferredWidth: 64
                
                onClicked: {
                    console.log("UserEvent: TajweedPlayButtonClicked");
                    
                    if (!tajweedPlayed) {
                        recitation.downloadAndPlayTajweed(root.surahId, root.verseId);
                        tajweedPlayed = true;
                        reporter.record("TajweedDownloadPlay", root.surahId+":"+root.verseId);
                    } else {
                        player.togglePlayback();
                        reporter.record("TajweedPlayPause");
                    }
                }
                
                animations: [
                    ScaleTransition
                    {
                        id: rotator2
                        fromX: 0.8
                        fromY: 0.8
                        toX: 1
                        toY: 1
                        delay: 500
                        duration: 1000
                        easingCurve: StockCurve.ElasticOut
                        
                        onCreationCompleted: {
                            tutorial.execBelowTitleBar( "tajweedPlay", qsTr("Tap on this Play button to begin a tajweed (pronunciation) tutorial of this ayat or download it if it is not yet downloaded."), 0, "r" );
                        }
                    }
                ]
            }
        }
    }

    function onReady(uri)
    {
        player.play(uri);
        rotator.play();
        
        if (showTajweed) {
            rotator2.play();
        }
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