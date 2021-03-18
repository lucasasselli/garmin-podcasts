using Toybox.Communications;
using Toybox.Application.Storage;

class EpisodesProviderWrapper {

    const EPISODE_MODE_MANUAL = 0;
    const EPISODE_MODE_RECENT = 1;

    var provider;

    function initialize(){
    	var mode = Application.getApp().getProperty("settingSyncMode");
        switch(mode){
            case EPISODE_MODE_RECENT:
            provider = new EpisodesProvider_Recent();
            break;

            case EPISODE_MODE_MANUAL:
            provider = new EpisodesProvider_Manual();
            break;
        }
    }

    function valid(displayError){
        return provider.valid(displayError);
    }

    function get(doneCallback, errorCallback){
        return provider.get(doneCallback, errorCallback);
    }
}