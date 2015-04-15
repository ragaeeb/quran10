import bb.cascades 1.3
import bb.cascades.maps 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();
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
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllOrigins)
                    {
                        for (var i = data.length-1; i >= 0; i--)
                        {
                            var current = data[i];
                            var name = current.name;
                            
                            offloader.renderMap(mapView, current.latitude, current.longitude, name, current.city, current.id);
                        }
                        
                        mapView.setLocationOnVisible();
                        navigationPane.parent.unreadContentCount = data.length;
                        
                        tutorial.execCentered("ummahMap", qsTr("Ahlus Sunnah is from all over the world. Here are where some of the students of knowledge, callers of Islam, and scholars of Islam are located or were from.\n\nYou can do a pinch gesture on this map to zoom in on specific cities, and tap on an individual to see their name.\n\nYou can then tap on the arrow to see a biography of them including their works."), "images/tutorial/pinch.png");
                    }
                }
                
                onCreationCompleted: {
                    tafsirHelper.fetchAllOrigins(mapView);
                }
            }
        }
    }
}