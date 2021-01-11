using Toybox.Application;
using Toybox.Media;

class PodcastsApp extends Application.AudioContentProviderApp {

    var contentDelegate;

    function initialize() {
        AudioContentProviderApp.initialize();
        contentDelegate = new ContentDelegate();
    }
    
    // Get a Media.ContentDelegate for use by the system to get and iterate through media on the device
    function getContentDelegate(arg) {
        return contentDelegate;
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
            return []; // FIXME: Is this correct?
        }
    }
    
    // Get the provider icon
    function getProviderIconInfo() {
        return new Media.ProviderIconInfo(Rez.Drawables.PlayerIcon, 0x00E2E2);
    }
}
