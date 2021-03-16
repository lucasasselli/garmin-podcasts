using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Communications;
using Toybox.Media;

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
        var playlist = StorageHelper.get(Constants.STORAGE_PLAYLIST, []);
        return playlist.size().toString() + " " + WatchUi.loadResource(Rez.Strings.episodes);
	}

    // Playback queue
	function callbackQueue(){
        var episodes = Storage.getValue(Constants.STORAGE_EPISODES);
        if ((episodes != null) && (episodes.size() != 0)) {
            // Episodes downloaded
            WatchUi.pushView(new PlaybackQueue(), new PlaybackQueueDelegate(), WatchUi.SLIDE_LEFT);
        } else {
            // No episodes
            WatchUi.pushView(new AlertView(Rez.Strings.errorNoEpisodes), null, WatchUi.SLIDE_LEFT);
        }
	}

    // Podcast subscription management
	function callbackPodcasts(){
        new PodcastsProviderWrapper().manage();
	}

    // Sync
	function callbackSync(){
    	var mode = Application.getApp().getProperty("settingSyncMode");
        if(mode == 1){ 
            // Recent
            Communications.startSync();
        }else{
            // Manual
            new EpisodeManager().show();
        }
	}

    // Settings
    function callbackSettings() {
        new Settings().show();
    }
}