using Toybox.Communications;
using Toybox.Application.Storage;

using CompactLib.Ui;

class PodcastProvider_Local {

    private var podcasts;

    function initialize(){
        self.podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
    }

    function valid(displayError){
        var validSubs = (podcasts.size() > 0);
        if(!validSubs && displayError){
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoSubscriptions);
            alert.show();
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