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
        var count = 0;
        //if autoPlaylist is enabled, then display the episode count as the downloaded count
        if (Application.getApp().getProperty("settingPlaylistAutoSelect")) {
            count = getDownloadedSize();
        //else display the size of the playlist
        } else {
            var playlist = StorageHelper.get(Constants.STORAGE_PLAYLIST, []);
            count = playlist.size().toString();
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

    // Playback queue
    function callbackQueue(){
        var downloadedCount = getDownloadedSize();
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