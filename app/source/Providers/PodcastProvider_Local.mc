using Toybox.Communications;
using Toybox.Application.Storage;

class PodcastProvider_Local extends PodcastProvider {

    private var podcasts;

    function initialize(){
        self.podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, []);
        PodcastProvider.initialize();
    }

    function valid(){
        return (podcasts.size() != 0);
    }

    function getPodcasts(podcasts, doneCallback, errorCallback){
        podcasts = self.podcasts;
        doneCallback.invoke();
    }

}