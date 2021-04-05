using Toybox.Communications;
using Toybox.Application.Storage;

class EpisodesProvider_Manual {

    private var episodes;

    function initialize(){
        self.episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
    }

    function valid(displayError){
        return true;
    }

    function get(doneCallback, errorCallback){
        doneCallback.invoke(episodes);
        return false;
    }

}