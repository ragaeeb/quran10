import bb.cascades 1.0
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
                            var name = current.displayName ? current.displayName : current.name;
                            
                            offloader.renderMap(mapView, current.latitude, current.longitude, name, current.city, current.id);
                        }
                        
                        mapView.setLocationOnVisible();
                        navigationPane.parent.unreadContentCount = data.length;
                    }
                }
                
                onCreationCompleted: {
                    tafsirHelper.fetchAllOrigins(mapView);
                }
            }
        }
    }
}