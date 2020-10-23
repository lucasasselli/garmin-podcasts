using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Media;

class ConfigurePlaybackMenu extends WatchUi.CheckboxMenu {

    function initialize() {
        CheckboxMenu.initialize({:title => Rez.Strings.titlePlaybackMenu});
        
        // Get the current stored playlist.
        var currentPlaylist = {};
        var playlist = StorageHelper.get(Constants.STORAGE_PLAYLIST, []);
        for (var i = 0; i < playlist.size(); ++i) {
            currentPlaylist[playlist[i]] = true;
        }

        // For each song in the playlist, precheck the item when adding it to the menu
        var episodes = StorageHelper.get(Constants.STORAGE_SAVED, []);
        
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

class ConfigurePlaybackMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var playlist = StorageHelper.get(Constants.STORAGE_PLAYLIST, []);

        // When an item is selected, add or remove it from the system playlist
        if (item.isChecked()) {
            playlist.add(item.getId());
        } else {
            playlist.remove(item.getId());
        }

        Storage.setValue(Constants.STORAGE_PLAYLIST, playlist);
    }

    function onDone() {
        Media.startPlayback(null);
    }

	function onBack(){
    	WatchUi.popView(WatchUi.SLIDE_RIGHT);    	
		return true;
	}
}
