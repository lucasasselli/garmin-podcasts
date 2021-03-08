using Toybox.Communications;
using Toybox.Application.Storage;

class ProviderWrapper extends PodcastProvider {

    private var provider;

    function initialize(){
    	var service = Application.getApp().getProperty("settingPodcstService");
        if(service == 1){ 
            // GPodder
            provider = new PodcastProvider_GPodder();
        }else{
            // Local provider
            provider = new PodcastProvider_Local();
        }
        PodcastProvider.initialize();
    }

    function valid(){
        return provider.valid();
    }

    function getPodcasts(podcasts, doneCallback, errorCallback){
        provider.getPodcasts(podcasts, doneCallback, errorCallback);
    }

}