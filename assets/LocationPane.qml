import bb.cascades 1.2
import bb.cascades.maps 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    Page
    {
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: TitleBar
        {
            id: tb
            title: qsTr("The Ummah") + Retranslate.onLanguageChanged
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}
            
            MapView
            {
                id: mapView
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                
                onCaptionButtonClicked: {
                    persist.invoke( "com.canadainc.Quran10.bio.previewer", "", "", "", focusedId );
                    reporter.record("OpenMapIndividual", focusedId);
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllOrigins)
                    {
                        for (var i = data.length-1; i >= 0; i--) {
                            offloader.renderMap(mapView, data[i]);
                        }
                        
                        mapView.setLocationOnVisible();
                        navigationPane.parent.unreadContentCount = data.length;
                        
                        tutorial.execCentered("ummahMap", qsTr("Ahlus Sunnah is from all over the world. Here are where some of the students of knowledge, callers of Islam, and scholars of Islam are located or were from."), "images/common/ic_help.png");
                        tutorial.execCentered("ummahPinch", qsTr("You can do a pinch gesture on this map to zoom in on specific cities to see them in more detail."), "images/common/pinch.png");
                        tutorial.execCentered("ummahTapInfo", qsTr("Tap on any of the individuals, and then tap on the arrow to open their biography and see their works.") );
                    }
                }
                
                onCreationCompleted: {
                    helper.fetchAllOrigins(mapView);
                }
            }
        }
    }
}