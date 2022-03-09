using Toybox.Application.Storage;

class PodcastsProviderBase {

    var remote;

    var podcasts;

    var busy;

    var doneCallback;
    var errorCallback;
    var progressCallback;

    function initialize(remote){
        self.podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        self.remote = remote;
    }

    function valid(){
        return true;
    }

    function get(doneCallback, errorCallback, progressCallback){
        self.doneCallback = doneCallback;
        self.errorCallback = errorCallback;
        self.progressCallback = progressCallback;

        // Check if provider is doing something is background
        if(busy){
            System.println("Podcast provider: busy...");
            return true;
        }

        if(remote){
            System.println("Podcast provider: Downloading subscriptions...");
            busy = true;
            download();
            return true;
        }else{
            System.println("Podcast provider: Subscriptions available locally...");
            done(podcasts);
            return false;
        }
    }

    function download(){

    }

    function add(podcast, doneCallback, errorCallback){
        self.doneCallback = doneCallback;
        self.errorCallback = errorCallback;
        busy = true;
    }

    function remove(podcast, doneCallback, errorCallback){
        self.doneCallback = doneCallback;
        self.errorCallback = errorCallback;
        busy = true;
    }

    function done(podcasts){
        if(doneCallback != null){
            doneCallback.invoke(podcasts);
        }
        busy = false;
    }

    function error(string){
        if(errorCallback != null){
            errorCallback.invoke(string);
        }
        busy = false;
    }

    function progress(progress){
        if(progressCallback != null){
            progressCallback.invoke(progress);
        }
    }
}