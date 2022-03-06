using Toybox.Application;
using Toybox.Media;
using Toybox.Time;
using Toybox.Application.Storage;
using Constants;

var podcastsProvider;

class PodcastsApp extends Application.AudioContentProviderApp {

    function initialize() {
        AudioContentProviderApp.initialize();
    }

    function initData(){
        // If the storage scheme as changed, delete the sotred data to avoid crashes
        var storageVersion = Storage.getValue(Constants.STORAGE_VERSION);
        if(storageVersion != Constants.STORAGE_VERSION_VALUE){
            System.println("Storage version changed! Deleting data...");
            Storage.clearValues();
            Storage.setValue(Constants.STORAGE_VERSION, Constants.STORAGE_VERSION_VALUE);
        }

        // Ensure media sanity!
        Utils.purgeBadMedia();

        // Starting download in background
        $.podcastsProvider = new PodcastsProviderWrapper();
        $.podcastsProvider.getSilent();
    }

    // Get a Media.ContentDelegate for use by the system to get and iterate through media on the device
    function getContentDelegate(arg) {
        return new ContentDelegate();
    }

    // Get a delegate that communicates sync status to the system for syncing media content to the device
    function getSyncDelegate() {
        var isManual = Storage.getValue(Constants.STORAGE_MANUAL_SYNC);
        if(isManual == true){
            return new SyncDelegate();
        }else{
            return new SyncDummy();
        }
    }

    // Get the initial view for configuring playback
    function getPlaybackConfigurationView() {
        initData();
        return new MainMenu().get();
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() {
        initData();
        return new MainMenu().get();
    }

    // Get the provider icon
    function getProviderIconInfo() {
        return new Media.ProviderIconInfo(Rez.Drawables.PlayerIcon, 0x00E2E2);
    }
}