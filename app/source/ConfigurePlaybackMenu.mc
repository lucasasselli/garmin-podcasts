using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Media;

// Menu to choose what songs to playback
class ConfigurePlaybackMenu extends WatchUi.CheckboxMenu {

    function initialize() {
    
        CheckboxMenu.initialize({:title => Rez.Strings.titlePlaybackMenu});
        
        // Get the current stored playlist.
        var currentPlaylist = {};
        var playlist = Utils.getSafeStorageArray(Constants.STORAGE_PLAYLIST);
        if (playlist != null) {
            for (var i = 0; i < playlist.size(); ++i) {
                currentPlaylist[playlist[i]] = true;
            }
        }

        // For each song in the playlist, precheck the item when adding it to the menu
        var episodes = Utils.getSafeStorageArray(Constants.STORAGE_SAVED);
        
        for (var i = 0; i < episodes.size(); i++) {
        
            var refId = episodes[i][Constants.EPISODE_MEDIA];       	
            var mediaObj = Utils.getSafeMedia(refId);

            if(mediaObj != null){
	            var episodeTitle = mediaObj.getMetadata().title;
	            var episodePodcast = mediaObj.getMetadata().artist;
	            
	            addItem(new WatchUi.CheckboxMenuItem(episodeTitle, episodePodcast, refId, currentPlaylist.hasKey(refId), {}));
            }
        }
    }
}

// Delegate for playback menu
class ConfigurePlaybackMenuDelegate extends WatchUi.Menu2InputDelegate {

    // Constructor
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    // When an item is selected, add or remove it from the system playlist
    function onSelect(item) {
        var playlist = Utils.getSafeStorageArray(Constants.STORAGE_PLAYLIST);

        if (item.isChecked()) {
            playlist.add(item.getId());
        } else {
            playlist.remove(item.getId());
        }

        Storage.setValue(Constants.STORAGE_PLAYLIST, playlist);
    }

    // Pop the view when done
    function onDone() {
        Media.startPlayback(null);
    }

    // Pop the view when back is pushed
    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
