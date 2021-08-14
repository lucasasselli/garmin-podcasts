using Toybox.Communications;
using Toybox.Application.Storage;

class EpisodesProvider_Manual {

    private var podcasts;
    private var episodes;

    function initialize(){
        self.episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
        self.podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
    }

    function valid(displayError){
        return true;
    }

    function get(doneCallback, errorCallback){
        doneCallback.invoke(podcasts, episodes);
        return false;
    }

}