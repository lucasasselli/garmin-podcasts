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
        add(Rez.Strings.menuPodcasts, null, method(:callbackPodcasts));
        add(Rez.Strings.menuSync, null, method(:callbackSync));
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

    // Podcast subscription management
    function callbackPodcasts(){
        var podcastProvider = new PodcastsProviderWrapper();
        podcastProvider.manage();
    }

    // Sync
    function callbackSync(){
        var mode = Application.getApp().getProperty("settingSyncMode");
        var provider = new EpisodesProviderWrapper();

        switch(mode){
            case EpisodesProviderWrapper.EPISODE_MODE_RECENT:
            if(provider.valid(true)){
                // Start sync
                Storage.setValue(Constants.STORAGE_MANUAL_SYNC, true);
                Communications.startSync();
            }
            break;

            case EpisodesProviderWrapper.EPISODE_MODE_MANUAL:
            var manager = new EpisodeManager();
            manager.show();
            break;
        }
    }

    // Settings
    function callbackSettings() {
        var settings = new Settings();
        settings.show();
    }
}