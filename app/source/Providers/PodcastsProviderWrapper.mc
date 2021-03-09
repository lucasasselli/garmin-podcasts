using Toybox.Communications;
using Toybox.Application.Storage;

class PodcastsProviderWrapper {

    private var provider;

    function initialize(){
    	var service = Application.getApp().getProperty("settingPodcstService");
        if(service == 1){ 
            // GPodder
            provider = new PodcastProvider_GPodder();
        }else{
            // Local
            provider = new PodcastProvider_Local();
        }
    }

    function valid(){
        return provider.valid();
    }

    function getPodcasts(doneCallback, errorCallback){
        return provider.getPodcasts(doneCallback, errorCallback);
    }

}