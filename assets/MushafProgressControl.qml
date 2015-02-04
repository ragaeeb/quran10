import bb.cascades 1.0

Container
{
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    leftPadding: 10; rightPadding: 10
    layout: DockLayout {}
    
    onVisibleChanged: {
        if (visible) {
            progressBar.scaleX = 1;
            opacity = 1;
            rt.play();
        } else {
            rt.stop();
        }
    }
    
    ImageView
    {
        id: progressBar
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        imageSource: "images/progress/mushaf_progress_bar.png"
        scaleX: 0
        
        animations: [
            ScaleTransition {
                id: st
                fromX: 1
                toX: 0
                duration: 1000
                easingCurve: StockCurve.QuarticIn
                
                onEnded: {
                    tt.fromOpacity = 1;
                    tt.toOpacity = 0;
                    tt.duration = 1000;
                    tt.easingCurve = StockCurve.QuinticIn;
                    tt.play();
                }
            }
        ]
    }
    
    Container
    {
        layout: DockLayout {}
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
        
        ImageView
        {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            imageSource: "images/progress/mushaf_circle.png"
            preferredHeight: 200
            preferredWidth: 200
            
            animations: [
                RotateTransition
                {
                    id: rt
                    fromAngleZ: 0
                    toAngleZ: 360
                    duration: 2000
                    easingCurve: StockCurve.SineInOut
                    repeatCount: AnimationRepeatCount.Forever
                }
            ]
        }
        
        Container
        {
            leftPadding: 10
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            
            Label
            {
                id: label
                textStyle.textAlign: TextAlign.Center
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
                textStyle.base: SystemDefaults.TextStyles.SmallText
                textStyle.fontWeight: FontWeight.Bold
                textStyle.color: Color.White
                opacity: 0.8
                text: qsTr("Downloading...") + Retranslate.onLanguageChanged
                multiline: true
            }
        }
    }
    
    animations: [
        FadeTransition {
            id: tt
            fromOpacity: 1
            toOpacity: 0
            duration: 500
            easingCurve: StockCurve.SineOut
            
            onEnded: {
                if (toOpacity == 0) {
                    visible = false;
                }
            }
        }
    ]
    
    function onProgressChanged(cookie, current, total)
    {
        visible = true;
        label.text = qsTr("Downloading...\n") + ( (100.0*current)/total ).toFixed(1) + "%";
        progressBar.scaleX = current/total;
        
        if (current == total) {
            st.play();
        }
    }
    
    function onDeflationProgressChanged(current, total)
    {
        visible = true;
        label.text = qsTr("Uncompressing...\n") + ( (100.0*current)/total ).toFixed(1) + "%";
        progressBar.scaleX = current/total;
    }
    
    onCreationCompleted: {
        queue.downloadProgress.connect(onProgressChanged);
        mushaf.deflationProgress.connect(onDeflationProgressChanged);
        mushaf.deflationDone.connect(st.play);
    }
}