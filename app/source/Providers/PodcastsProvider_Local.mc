using Toybox.Communications;
using Toybox.Application.Storage;

class PodcastProvider_Local {

    private var podcasts;

    function initialize(){
        self.podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, []);
    }

    function valid(displayError){
        var validSubs = (podcasts.size() > 0);
        if(!validSubs && displayError){
            WatchUi.pushView(new AlertView(Rez.Strings.errorNoSubscriptions), null, WatchUi.SLIDE_LEFT); 
        }
        return validSubs;
    }

    function get(doneCallback, errorCallback){
        doneCallback.invoke(self.podcasts);
    }

    function manage(){
        var manager = new SubscriptionManager();
        manager.show();
    }
}