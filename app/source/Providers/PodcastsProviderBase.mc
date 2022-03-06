
class PodcastsProviderBase {

    var podcasts;

    var busy;
    var downloaded;

    var doneCallback;
    var errorCallback;

    function initialize(){
        podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        downloaded = false;
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