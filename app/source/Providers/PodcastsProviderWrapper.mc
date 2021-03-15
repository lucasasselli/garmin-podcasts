using Toybox.Communications;
using Toybox.Application.Storage;

class PodcastsProviderWrapper {

    private var provider;

    function initialize(){
    	var service = Application.getApp().getProperty("settingPodcastService");
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

    function get(doneCallback, errorCallback){
        return provider.get(doneCallback, errorCallback);
    }

}