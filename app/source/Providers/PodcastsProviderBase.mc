
class PodcastsProviderBase {

    var podcasts;

    var busy;
    var downloaded;

    var doneCallback;
    var errorCallback;
    var progressCallback;

    function initialize(){
        podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        downloaded = false;
    }

    function valid(){
        return true;
    }

    function get(doneCallback, errorCallback, porgressCallback){
        self.errorCallback = errorCallback;
        self.doneCallback = doneCallback;
        self.progressCallback = progressCallback;

        if(busy){
            System.println("Podcast provider is already running!");
            return true;
        }else{
            if(downloaded){
                System.println("Podcast provider download already has data!");
                done(podcasts);
                return false;
            }else{
                System.println("Podcast provider starting download...");
                busy = true;
                download();
                return true;
            }
        }
    }

    function download(){

    }

    function add(context){
        podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        podcasts.put(Utils.hash(context[Constants.PODCAST_URL]), context);
        Storage.setValue(Constants.STORAGE_SUBSCRIBED, podcasts);

        return false;
    }

    function remove(context){
        podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        podcasts.remove(context);
        Storage.setValue(Constants.STORAGE_SUBSCRIBED, podcasts);

        // Trigger data cleanup
        Utils.purgeBadMedia();

        return false;
    }

    function done(podcasts){
        if(doneCallback != null){
            doneCallback.invoke(podcasts);
        }
        if(podcasts.size() > 0){
            downloaded = true;
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