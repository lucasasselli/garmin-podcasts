using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Communications;
using Toybox.Media;

using CompactLib.Ui;

class MainMenu extends Ui.CompactMenu {

    function initialize(){
        CompactMenu.initialize(Rez.Strings.AppName);
    }

    function build(){
        add(Rez.Strings.menuQueue, method(:getQueueLabel), method(:callbackQueue));
        add(Rez.Strings.menuPodcasts, null, method(:callbackManagePodcasts));
        add(Rez.Strings.menuEpisodes, null, method(:callbackManageEpisodes));
        add(Rez.Strings.menuSettings, null, method(:callbackSettings));
    }

    // Return playback queue size string
    function getQueueLabel(){
        var count = 0;
        //if autoQueue is enabled, then display the episode count as the downloaded count
        if (Application.getApp().getProperty("settingQueueAutoSelect")) {
            count = getDownloadedSize();
        //else display the size of the queue
        } else {
            count = getQueueSize();
        }
        return count + " " + WatchUi.loadResource(Rez.Strings.episodes);
    }

    //return the number of downloaded episodes
    function getDownloadedSize(){
        var episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
        var downloadedCount = 0;
        for(var i=0; i<episodes.size(); i++){
            if(episodes.values()[i][Constants.EPISODE_MEDIA] != null){
                downloadedCount++;
            }
        }
        return downloadedCount;
    }

    function getQueueSize(){
        var episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
        var queueCount = 0;
        for(var i=0; i<episodes.size(); i++){
            if(episodes.values()[i][Constants.EPISODE_IN_QUEUE] == true){
                queueCount++;
            }
        }
        return queueCount;
    }

    // Playback queue
    function callbackQueue(){
        var downloadedCount = getDownloadedSize();
        if (downloadedCount > 0) {
            // Episodes downloaded
            var autoQueue = Application.getApp().getProperty("settingQueueAutoSelect");
            if(autoQueue){
                var prompt = new Ui.CompactPrompt(Rez.Strings.confirmPlayback, method(:startPlayback), null);
                prompt.show();
            }else{
                WatchUi.pushView(new Queue(), new QueueDelegate(), WatchUi.SLIDE_LEFT);
            }
        } else {
            // No episodes
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoQueueEpisodes);
            alert.show();
        }
    }

    function startPlayback(){
        // NOTE: Popping the view before starting playback causes problems...
        Media.startPlayback(null);
    }

    // Manage subscriptions
    function callbackManagePodcasts(){
        $.podcastsProvider.get(method(:podcastsDone));
    }

    // Manage subscriptions - Subscriptions ready
    function podcastsDone(hasProgress, podcasts){
        var manager = new SubscriptionManager();
        if(hasProgress){
            manager.switchTo();
        }else{
            manager.show();
        }
    }

    // Manage episodes
    function callbackManageEpisodes(){
        var episodeManager = new EpisodeManager();
        episodeManager.show();
    }

    // Settings
    function callbackSettings() {
        var settings = new Settings();
        settings.show();
    }
}