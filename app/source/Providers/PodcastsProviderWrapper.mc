using Toybox.Communications;
using Toybox.Application;
using Toybox.WatchUi;

using CompactLib.Ui;

class PodcastsProviderWrapper {

    enum {
        PODCAST_SERVICE_LOCAL,
        PODCAST_SERVICE_GPODDER
    }

    private var provider;

    private var callback;
    private var progressBar;

    function initialize(){
        var service = Application.getApp().getProperty("settingPodcastService");
        switch(service){
            case PODCAST_SERVICE_LOCAL:
            provider = new PodcastsProvider_Local();
            break;

            case PODCAST_SERVICE_GPODDER:
            provider = new PodcastsProvider_GPodder();
            break;
        }
    }

    function getSilent(){
        return provider.get(null, null, null);
    }

    function get(callback){
        self.callback = callback;
        self.progressBar = null;
        if(provider.valid()){
            if(provider.remote){
                progressBar = new WatchUi.ProgressBar(WatchUi.loadResource(Rez.Strings.loading), null);
                WatchUi.pushView(progressBar, new CompactLib.Utils.RemoteProgressDelegate(), WatchUi.SLIDE_LEFT);
            }
            provider.get(method(:doneCallback), method(:errorHandler), method(:progressCallback));
        }else{
            errorHandler(Rez.Strings.errorNoCredentials);
        }
    }

    function add(podcast, callback){
        self.callback = callback;
        self.progressBar = null;
        if(provider.remote){
            progressBar = new WatchUi.ProgressBar(WatchUi.loadResource(Rez.Strings.loading), null);
            WatchUi.switchToView(progressBar, new CompactLib.Utils.RemoteProgressDelegate(), WatchUi.SLIDE_LEFT);
        }
        provider.add(podcast, method(:doneCallback), method(:errorHandler));
    }

    function remove(podcast, callback){
        self.callback = callback;
        self.progressBar = null;
        if(provider.remote){
            progressBar = new WatchUi.ProgressBar(WatchUi.loadResource(Rez.Strings.loading), null);
            WatchUi.switchToView(progressBar, new CompactLib.Utils.RemoteProgressDelegate(), WatchUi.SLIDE_LEFT);
        }
        provider.remove(podcast, method(:doneCallback), method(:errorHandler));
    }

    function errorHandler(msg){
        var alert = new Ui.CompactAlert(msg);
        if(progressBar != null){
            alert.switchTo();
        }else{
            alert.show();
        }
    }

    function doneCallback(podcasts){
        if(callback != null){
            callback.invoke((progressCallback != null), podcasts);
        }
    }

    function progressCallback(progress){
        if(progressBar != null){
            progressBar.setProgress(progress);
        }
    }
}