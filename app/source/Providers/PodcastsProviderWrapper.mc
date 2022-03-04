using Toybox.Communications;
using Toybox.Application;

(:background)
class PodcastsProviderWrapper {

    const PODCAST_SERVICE_LOCAL = 0;
    const PODCAST_SERVICE_GPODDER = 1;

    private var provider;

    function initialize(){
        var service = Application.getApp().getProperty("settingPodcastService");
        switch(service){
            case PODCAST_SERVICE_LOCAL:
            provider = new PodcastProvider_Local();
            break;

            case PODCAST_SERVICE_GPODDER:
            provider = new PodcastProvider_GPodder();
            break;
        }
    }

    function valid(displayError){
        return provider.valid(displayError);
    }

    function get(doneCallback, errorCallback){
        return provider.get(doneCallback, errorCallback);
    }

    function setProgressCallback(callback){
        provider.setProgressCallback(callback);
    }

    function manage(){
        provider.manage();
    }
}