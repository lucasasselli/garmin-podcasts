using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Communications;
using Toybox.Media;

class MainMenu extends CompactMenu {

    function initialize(){
		CompactMenu.initialize(Rez.Strings.AppName);
    }

	function build(){
		// add(Rez.Strings.menuPlayer, method(:getPlaybackInfo), method(:callbackPlayer));
		add(Rez.Strings.menuQueue, method(:getQueueSize), method(:callbackQueue));
        add(Rez.Strings.menuPodcasts, null, method(:callbackPodcasts));
		add(Rez.Strings.menuSync, null, method(:callbackSync));
		add(Rez.Strings.menuSettings, null, method(:callbackSettings));
	}

    // Get playback info
	function getPlaybackInfo(){
        var now = StorageHelper.get(Constants.STORAGE_NOWPLAYING, null);
        if(now != null){
            var ref = new Media.ContentRef(now[Constants.NOWPLAYING_MEDIA], Media.CONTENT_TYPE_AUDIO);
            if(ref != null){
                var metadata = Media.getCachedContentObj(ref).getMetadata();
                return metadata.title;
            }
        }

        return "";
	}

    // Return playback queue size string
	function getQueueSize(){
        var playlist = StorageHelper.get(Constants.STORAGE_PLAYLIST, []);
        return playlist.size().toString() + " " + WatchUi.loadResource(Rez.Strings.episodes);
	}

    // Playback queue
	function callbackPlayer(){
    	WatchUi.popView(WatchUi.SLIDE_RIGHT);    	
	}

    // Playback queue
	function callbackQueue(){
        var episodes = Storage.getValue(Constants.STORAGE_SAVED);
        if ((episodes != null) && (episodes.size() != 0)) {
            // Episodes downloaded
            WatchUi.pushView(new ConfigurePlaybackMenu(), new ConfigurePlaybackMenuDelegate(), WatchUi.SLIDE_LEFT);
        } else {
            // No episodes
            WatchUi.pushView(new AlertView(Rez.Strings.errorNoEpisodes), null, WatchUi.SLIDE_LEFT);
        }
	}

    // Podcast subscription management
	function callbackPodcasts(){
    	var service = Application.getApp().getProperty("settingService");
        if(service == 0){
            // Manual
            new SyncConfigurationManual().show();
        } else {
            // gPodder
            WatchUi.pushView(new AlertView(Rez.Strings.msgCheckPhone), null, WatchUi.SLIDE_LEFT);
            Communications.openWebPage(Constants.URL_GPODDER_ROOT, {}, null);
        }
	}

    // Sync
	function callbackSync(){
    	var service = Application.getApp().getProperty("settingService");
        if(service == 0){
            // Manual
            var podcasts = Storage.getValue(Constants.STORAGE_SUBSCRIBED);
            if ((podcasts != null) && (podcasts.size() != 0)) {
                // Start sync
                Communications.startSync();
            } else {
                // No podcasts
                WatchUi.pushView(new AlertView(Rez.Strings.errorNoSubscriptions), null, WatchUi.SLIDE_LEFT);
            }
        }else{
            // gPodder
            var gPodder = new GPodder();
            if(gPodder.valid()){
                // Start sync
                Communications.startSync();
            }else{
                // No credentials
                WatchUi.pushView(new AlertView(Rez.Strings.errorNoCredentials), null, WatchUi.SLIDE_LEFT);
            }
        }
	}

    // Settings
    function callbackSettings() {
        new Settings().show();
    }
}