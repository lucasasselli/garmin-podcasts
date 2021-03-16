using Toybox.Communications;
using Toybox.Application.Storage;

class PodcastProvider_Local {

    private var podcasts;

    function initialize(){
        self.podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, []);
    }

    function valid(){
        return (podcasts.size() != 0);
    }

    function get(doneCallback, errorCallback){
        doneCallback.invoke(self.podcasts);
        return false;
    }

    function manage(){
        new SubscriptionManager().show();
    }
}