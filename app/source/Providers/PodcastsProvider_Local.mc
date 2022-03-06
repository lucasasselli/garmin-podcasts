using Toybox.Communications;
using Toybox.Application.Storage;

using CompactLib.Ui;

class PodcastProvider_Local extends PodcastsProviderBase{

    function initialize(){
        PodcastsProviderBase.initialize();

        downloaded = true;
    }

    function valid(displayError){
        var validSubs = (podcasts.size() > 0);
        if(!validSubs && displayError){
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoSubscriptions);
            alert.show();
        }
        return validSubs;
    }

    function manage(){
        var manager = new SubscriptionManager();
        manager.show();
    }
}