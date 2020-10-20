using Toybox.Application;

class PodcastsApp extends Application.AudioContentProviderApp {

    function initialize() {
        AudioContentProviderApp.initialize();
    }
    
    function getSettingsView() {
    	return [ new Rez.Menus.SettingsMain(), new SettingsMainDelegate() ];
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
        return [ new Rez.Menus.MainMenu(), new MainMenuDelegate() ];
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() {
        return [ new Rez.Menus.SyncConfigurationMenu(), new SyncConfigurationDelegate() ];
    }
    
    // Get the provider icon
    function getProviderIconInfo() {
        return new Media.ProviderIconInfo(Rez.Drawables.PlayerIcon, 0x00E2E2);
    }
}
