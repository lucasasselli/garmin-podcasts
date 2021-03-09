using Toybox.Communications;
using Toybox.Application.Storage;

class DownloadsProviderWrapper {

    var provider;

    function initialize(){
    	var mode = Application.getApp().getProperty("settingSyncMode");
        if(mode == 1){ 
            // Recent
            provider = new DownloadsProvider_Recent();
        }else{
            // Manual
            provider = new DownloadsProvider_Manual();
        }
    }

    function valid(){
        return provider.valid();
    }

    function get(doneCallback, errorCallback){
        return provider.get(doneCallback, errorCallback);
    }
}