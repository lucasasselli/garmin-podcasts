using Toybox.Background;
using Toybox.System;

(:background)
class BackgroundDelegate extends System.ServiceDelegate {

    var provider;

    function initialize(){
        System.ServiceDelegate.initialize();
    }

    function onTemporalEvent() {
        System.println("Running background service...");
        provider = new PodcastsProviderWrapper();
        if(provider.valid(false)){
            provider.get(method(:podcastsDone), null);
        }
    }

    function podcastsDone(podcasts){
        System.println("Background service complete!");
        Background.exit(null);
    }
}