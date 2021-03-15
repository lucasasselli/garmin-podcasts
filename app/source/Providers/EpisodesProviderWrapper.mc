using Toybox.Communications;
using Toybox.Application.Storage;

class EpisodesProviderWrapper {

    var provider;

    function initialize(){
    	var mode = Application.getApp().getProperty("settingSyncMode");
        if(mode == 1){ 
            // Recent
            provider = new EpisodesProvider_Recent();
        }else{
            // Manual
            provider = new EpisodesProvider_Manual();
        }
    }

    function valid(){
        return provider.valid();
    }

    function get(doneCallback, errorCallback){
        return provider.get(doneCallback, errorCallback);
    }
}