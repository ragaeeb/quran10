import bb.cascades 1.2
import bb.system 1.0
import com.canadainc.data 1.0

Container
{
    topPadding: 10; bottomPadding: 10; leftPadding: 10; rightPadding: 10
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    property bool played: false
    
    function cleanUp()
    {
        if (played) {
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
        preferredHeight: 96
        preferredWidth: 96
        
        onClicked: {
            console.log("UserEvent: DownloadPlayButtonClicked");
            
            if (!played)
            {
                if ( recitation.tajweedAvailable(root.surahId, root.verseId) ) {
                    sld.show();
                } else {
                    processPlay(0);
                }
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
    
    SeekBar {
        onCreationCompleted: {
            rotator.play();
        }
    }

    function onReady(uri)
    {
        player.play(uri);
        rotator.play();
    }
    
    onCreationCompleted: {
        recitation.readyToPlay.connect(onReady);
        
        sld.appendItem( qsTr("Recitation"), true, true );
        sld.appendItem( qsTr("Tajweed") );
    }
    
    function processPlay(selectedIndex)
    {
        if (selectedIndex == 0) {
            recitation.downloadAndPlay(root.surahId, root.verseId);
            reporter.record("AyatDownloadPlay", root.surahId+":"+root.verseId);
        } else {
            recitation.downloadAndPlayTajweed(root.surahId, root.verseId);
            reporter.record("TajweedDownloadPlay", root.surahId+":"+root.verseId);
        }
        
        played = true;
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
        },
        
        SystemListDialog
        {
            id: sld
            body: qsTr("Choose which type of audio of this verse you want to play:") + Retranslate.onLanguageChanged
            title: qsTr("Recitation or Tajweed?") + Retranslate.onLanguageChanged
            cancelButton.label: qsTr("Cancel") + Retranslate.onLanguageChanged
            confirmButton.label: qsTr("OK") + Retranslate.onLanguageChanged
            
            onFinished: {
                console.log("**S DFLKJ");
                if (value == SystemUiResult.ConfirmButtonSelection) {
                    console.log("**S DFLKJ222");
                    console.log(selectedIndices);
                    processPlay(selectedIndices[0]);
                    console.log("**S DFLKJ444");
                }
            }
        }
    ]
}