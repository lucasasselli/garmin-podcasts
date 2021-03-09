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
        var episodes = Storage.getValue(Constants.STORAGE_SAVED);
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
    	var service = Application.getApp().getProperty("settingPodcastService");
        if(service == 0){
            // Manual
            new SubscriptionManager().show();
        } else {
            // gPodder
            WatchUi.pushView(new AlertView(Rez.Strings.msgCheckPhone), null, WatchUi.SLIDE_LEFT);
            Communications.openWebPage(Constants.URL_GPODDER_ROOT, {}, null);
        }
        // TODO: 
	}

    // Sync
	function callbackSync(){
        new EpisodeManager().show();
        // // TODO:
    	// var service = Application.getApp().getProperty("settingPodcastService");
        // if(service == 0){
        //     // Manual
        //     var podcasts = Storage.getValue(Constants.STORAGE_SUBSCRIBED);
        //     if ((podcasts != null) && (podcasts.size() != 0)) {
        //         // Start sync
        //         Communications.startSync();
        //     } else {
        //         // No podcasts
        //         WatchUi.pushView(new AlertView(Rez.Strings.errorNoSubscriptions), null, WatchUi.SLIDE_LEFT);
        //     }
        // }else{
        //     // gPodder
        //     var gPodder = new GPodder();
        //     if(gPodder.valid()){
        //         // Start sync
        //         Communications.startSync();
        //     }else{
        //         // No credentials
        //         WatchUi.pushView(new AlertView(Rez.Strings.errorNoCredentials), null, WatchUi.SLIDE_LEFT);
        //     }
        // }
	}

    // Settings
    function callbackSettings() {
        new Settings().show();
    }
}