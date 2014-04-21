import bb.cascades 1.0

NavigationPane
{
    id: navigationPane

    onPopTransitionEnded: {
        page.destroy();
    }
    
    SearchPage {
        id: sp
    }
}