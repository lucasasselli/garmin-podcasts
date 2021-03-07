using Toybox.Application.Storage;
using Toybox.Media;

class Utils {

	function findArrayField(array, field, value){
		if (array == null){
			return null;
		}
		for(var i=0; i<array.size(); i++){
			var x = array[i];
			if (field < x.size()){
				if (x[field] == value){
					return x;
				}
			}
		}
		
		return null;
	}

    function arraySwap(array, i, j){
        var temp = array[i];
        array[i] = array[j];
        array = temp;
    }
	
	function getArrayField(array, field){
	
		if (array == null){
			return [];
		}
		
		var x = [];
		
		for(var i=0; i<array.size(); i++){
			x.add(array[i][field]);
		}
		
		return x;
	}
	
	function getSafeDictKey(dict, key){
        if(dict.hasKey(key)) {
        	return dict[key];
        }else{
        	return null;
        }
	}

	function getSafeMedia(refId){
		var mediaObj = null;
		if(refId != null){
			try{
				var ref = new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);
				mediaObj = Media.getCachedContentObj(ref);
			}catch(ex){
				mediaObj = null;
			}
		}
		return mediaObj;
	}

    function purgeBadMedia(){

        var episodes = StorageHelper.get(Constants.STORAGE_SAVED, []);

        // Purge medias without episode
        var medias = Media.getContentRefIter({:contentType => Media.CONTENT_TYPE_AUDIO});
        if (medias != null) {
            var media = medias.next();
            while (media != null) {
                if(Utils.findArrayField(episodes, Constants.EPISODE_MEDIA, media.getId()) == null){
                    System.println("Media " + media.getId() + " is not used by an episode. Deleting...");
                    var ref = new Media.ContentRef(media.getId(), Media.CONTENT_TYPE_AUDIO);
                    Media.deleteCachedItem(ref);
                }
                media = medias.next();
            }
        }

        // Purge episodes without media
        var purgedEpisodes = [];
        for (var i = 0; i < episodes.size(); i++) {
            var mediaObj = Utils.getSafeMedia(episodes[i][Constants.EPISODE_MEDIA]);

            if(mediaObj != null){
                purgedEpisodes.add(episodes[i]);
            }else{
                System.println("Episode " + episodes[i][Constants.EPISODE_ID] + " doesn't have a media. Deleting...");
            }
        }
        Storage.setValue(Constants.STORAGE_SAVED, purgedEpisodes);

        // Purge playlist episodes
        var playlist = StorageHelper.get(Constants.STORAGE_PLAYLIST, []);
        var purgedPlaylist = [];
    	for(var i=0; i<playlist.size(); i++){
			var x = Utils.findArrayField(purgedEpisodes, Constants.EPISODE_MEDIA, playlist[i]);
    		if(x != null){  		
                purgedPlaylist.add(playlist[i]);
            }else{
                System.println("Media " + playlist[i] + " doesn't exist anymore. Deleting from playlist...");
            }
        }
        Storage.setValue(Constants.STORAGE_PLAYLIST, purgedPlaylist);
    }
}