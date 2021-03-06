using Toybox.Application;
using Toybox.Media;

class PodcastsApp extends Application.AudioContentProviderApp {

    function initialize() {

        // If the storage scheme as changed, delete the sotred data to avoid crashes
        var storage_version = Storage.getValue(Constants.STORAGE_VERSION);
        if(storage_version != Constants.STORAGE_VERSION_VALUE){
            Storage.clearValues();
            Storage.setValue(Constants.STORAGE_VERSION, Constants.STORAGE_VERSION_VALUE);
        }

        // Ensure media sanity!
        Utils.purgeBadMedia();

        AudioContentProviderApp.initialize();
    }
    
    // Get a Media.ContentDelegate for use by the system to get and iterate through media on the device
    function getContentDelegate(arg) {
        return new ContentDelegate();
    }

    // Get a delegate that communicates sync status to the system for syncing media content to the device
    function getSyncDelegate() {
        var is_manual = Storage.getValue(Constants.STORAGE_MANUAL_SYNC);
        if(is_manual == true){
            return new SyncDelegate();
        }else{
            return new SyncDummy();
        }
    }

    // Get the initial view for configuring playback
    function getPlaybackConfigurationView() {
        return new MainMenu().get();
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() {
        return new MainMenu().get();
    }
    
    // Get the provider icon
    function getProviderIconInfo() {
        return new Media.ProviderIconInfo(Rez.Drawables.PlayerIcon, 0x00E2E2);
    }
}
