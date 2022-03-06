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
        add(Rez.Strings.menuQueue, method(:getQueueSize), method(:callbackQueue));
        add(Rez.Strings.menuPodcasts, null, method(:callbackManagePodcasts));
        add(Rez.Strings.menuEpisodes, null, method(:callbackManageEpisodes));
        add(Rez.Strings.menuSettings, null, method(:callbackSettings));
    }

    // Return playback queue size string
    function getQueueSize(){
        var playlist = StorageHelper.get(Constants.STORAGE_PLAYLIST, []);
        return playlist.size().toString() + " " + WatchUi.loadResource(Rez.Strings.episodes);
    }

    // Playback queue
    function callbackQueue(){
        var episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
        var downloadedCount = 0;
        for(var i=0; i<episodes.size(); i++){
            if(episodes.values()[i][Constants.EPISODE_MEDIA] != null){
                downloadedCount++;
            }
        }
        if (downloadedCount > 0) {
            // Episodes downloaded
            WatchUi.pushView(new PlaybackQueue(), new PlaybackQueueDelegate(), WatchUi.SLIDE_LEFT);
        } else {
            // No episodes
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoQueueEpisodes);
            alert.show();
        }
    }

    // Manage subscriptions
    function callbackManagePodcasts(){
        $.podcastsProvider.get(method(:podcastsDone));
    }

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