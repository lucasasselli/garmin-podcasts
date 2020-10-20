using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Communications;

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {
    
    function onSelect(item) {
        if (item.getId() == :queue) {
            // Playback quueue
            var episodes = Storage.getValue(Constants.STORAGE_SAVED);
            if ((episodes != null) && (episodes.size() != 0)) {
                // Episodes downloaded
			    WatchUi.pushView(new ConfigurePlaybackMenu(), new ConfigurePlaybackMenuDelegate(), WatchUi.SLIDE_LEFT);
            } else {
                // No episodes
			    WatchUi.pushView(new ErrorView(Rez.Strings.errorNoEpisodes), null, WatchUi.SLIDE_LEFT);
            }
        } else if (item.getId() == :podcasts) {  
            // Podcast subscription management
			WatchUi.pushView(new Rez.Menus.SyncConfigurationMenu(), new SyncConfigurationDelegate(), WatchUi.SLIDE_LEFT);
        } else if (item.getId() == :sync) {  
            // Start sync
            Communications.startSync();
        } else if (item.getId() == :settings) {  
            // Settings
			WatchUi.pushView(new Rez.Menus.SettingsMain(), new SettingsMainDelegate(), WatchUi.SLIDE_LEFT);
		}
    }
}