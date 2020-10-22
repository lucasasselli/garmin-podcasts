using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Communications;

class MainMenu extends CompactMenu {

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
        var playlist = Utils.getSafeStorageArray(Constants.STORAGE_PLAYLIST);
        if(playlist == null){
            return "0 " + WatchUi.loadResource(Rez.Strings.episodes);
        }else{
            return playlist.size().toString() + " " + WatchUi.loadResource(Rez.Strings.episodes);
        }
	}

    // Playback queue
	function callbackQueue(){
        var episodes = Storage.getValue(Constants.STORAGE_SAVED);
        if ((episodes != null) && (episodes.size() != 0)) {
            // Episodes downloaded
            WatchUi.pushView(new ConfigurePlaybackMenu(), new ConfigurePlaybackMenuDelegate(), WatchUi.SLIDE_LEFT);
        } else {
            // No episodes
            WatchUi.pushView(new ErrorView(Rez.Strings.errorNoEpisodes), null, WatchUi.SLIDE_LEFT);
        }
	}

    // Podcast subscription management
	function callbackPodcasts(){
        new SyncConfiguration().show();
	}

    // Sync
	function callbackSync(){
        var podcasts = Storage.getValue(Constants.STORAGE_SUBSCRIBED);
        if ((podcasts != null) && (podcasts.size() != 0)) {
            // Start sync
            Communications.startSync();
        } else {
            // No podcasts
            WatchUi.pushView(new ErrorView(Rez.Strings.errorNoSubscriptions), null, WatchUi.SLIDE_LEFT);
        }
	}

    // Settings
    function callbackSettings() {
        new Settings().show();
    }
}