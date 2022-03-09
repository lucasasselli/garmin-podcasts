using Toybox.Application.Storage;

class PodcastsProviderBase {

    hidden var remote;

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

    function get(doneCallback, errorCallback, porgressCallback){
        self.errorCallback = errorCallback;
        self.doneCallback = doneCallback;
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

    function add(podcast){
        podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        podcasts.put(Utils.hash(podcast[Constants.PODCAST_URL]), podcast);
        Storage.setValue(Constants.STORAGE_SUBSCRIBED, podcasts);

        return false;
    }

    function remove(podcast){
        podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        podcasts.remove(Utils.hash(podcast[Constants.PODCAST_URL]));
        Storage.setValue(Constants.STORAGE_SUBSCRIBED, podcasts);

        // Trigger data cleanup
        Utils.purgeBadMedia();

        return false;
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