using Toybox.Application;

class PodcastsApp extends Application.AudioContentProviderApp {

    function initialize() {
        AudioContentProviderApp.initialize();
    }
    
    // Get a Media.ContentDelegate for use by the system to get and iterate through media on the device
    function getContentDelegate(arg) {
        return new ContentDelegate();
    }

    // Get a delegate that communicates sync status to the system for syncing media content to the device
    function getSyncDelegate() {
        return new SyncDelegate();
    }

    // Get the initial view for configuring playback
    function getPlaybackConfigurationView() {
        return new MainMenu().get();
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() {
    	var service = Application.getApp().getProperty("settingService");
        if(service == 0){
            // Manual
            return new SyncConfigurationManual().get();
        }else{
            // gPodder
            return [];
        }
    }
    
    // Get the provider icon
    function getProviderIconInfo() {
        return new Media.ProviderIconInfo(Rez.Drawables.PlayerIcon, 0x00E2E2);
    }
}
