using Toybox.Communications;
using Toybox.Media;
using Toybox.Application.Storage;

class SyncDelegate extends Communications.SyncDelegate {

	var podcasts;
	var podcastsIndex;
	
	var episodes;
	var episodesUrl;
	var episodesIndex;
	
	var saved;
	
	var settingEpisodesPerPodcast;

    function initialize() {
        SyncDelegate.initialize();
    }
    
    // Called when the system starts a sync of the app.
    // The app should begin to download songs chosen in the configure
    // sync view .
    function onStartSync() {
    
    	// Set data
    	podcasts = Utils.getSafeStorageArray(Constants.STORAGE_SUBSCRIBED);
        podcastsIndex = 0;
        
        episodes = [];
        episodesUrl = [];
	    episodesIndex = 0;
        
    	saved = Utils.getSafeStorageArray(Constants.STORAGE_SAVED);
    	
    	// Get settings
    	settingEpisodesPerPodcast = Application.getApp().getProperty("settingEpisodes").toNumber();
              
    	getNextPodcast();
    }

    // Called by the system to determine if the app needs to be synced.
    function isSyncNeeded() {
        return true;
    }

    // Called when the user chooses to cancel an active sync.
    function onStopSync() {
        throwSyncError(null);
    }
    
    function throwSyncError(msg){
    	Communications.cancelAllRequests();
    	Media.notifySyncComplete(msg);
    }
    
    function cleanMedia(){
    	for(var i=0; i<saved.size(); i++){
			var x = Utils.findArrayField(episodes, Constants.EPISODE_ID, saved[i][Constants.EPISODE_ID]);
    		if(x == null){  		
    			System.println("Episode ID " + saved[i][Constants.EPISODE_ID] + " no longer needed!");
    			    			
				try{
    				Media.deleteCachedItem(new Media.ContentRef(saved[i][Constants.EPISODE_ID], Media.CONTENT_TYPE_AUDIO));
				} catch (ex){
					// Do nothing.
				}
    		}
    	}
    }
    
    function getNextPodcast(){		
    	if(podcastsIndex < podcasts.size()){	
    		Remote.request(Constants.URL_EPISODES, {"id" => podcasts[podcastsIndex][Constants.PODCAST_ID], "max" => settingEpisodesPerPodcast}, method(:onPodcast));
    	} else {
			Storage.setValue(Constants.STORAGE_SAVED, episodes);		
			cleanMedia();		
			Media.notifySyncComplete(null);		
		}
    }
    
    function onPodcast(responseCode, data) {
        if (responseCode == 200) { 
                      	
        	var items = Utils.getSafeDictKey(data, "items");
        	var artworkUrl = null;
        	
        	if(items != null){
				for(var i=0; i<items.size(); i++){
				
					var episode = new [Constants.EPISODE_DATA_SIZE];
					
					if(artworkUrl == null && items[0]["feedImage"] != null){
						artworkUrl = items[0]["feedImage"];
					}
		    				
					episode[Constants.EPISODE_ID] = items[i]["id"];
					episode[Constants.EPISODE_PODCAST] = podcasts[podcastsIndex][Constants.PODCAST_ID];
					episodes.add(episode);	
					
					var mediaObj = null;
					try {
						var existing = Utils.findArrayField(saved, Constants.EPISODE_ID, episode[Constants.EPISODE_ID]);
						var ref = new Media.ContentRef(existing[Constants.EPISODE_MEDIA], Media.CONTENT_TYPE_AUDIO);
						mediaObj = Media.getCachedContentObj(ref);
					} catch(ex) {
						mediaObj = null;
					}
		
		    		if(mediaObj == null){				
						episodesUrl.add(items[i]["enclosureUrl"]);
		    		}else{
		    			episodesUrl.add(null);
		    			System.println("Episode ID " + episode[Constants.EPISODE_ID] + " already downloaded!");
		    		}	  					
				}
				
				// Request Artwork
				if(artworkUrl != null && Storage.getValue(podcasts[podcastsIndex][Constants.PODCAST_ID]) == null){
					System.println("Downloading artwork for  " + podcasts[podcastsIndex][Constants.PODCAST_ID] + " at " + artworkUrl);
					
					var options = {
						:maxWidth => 127,
						:maxHeight => 127
					};

				   	Communications.makeImageRequest(
				   		artworkUrl,
				   		null,
				   		options,
				   		method(:onArtwork));
			   	}else{
			   		// No Artwork
			   		getNextEpisode();
			   	}
		   	}
        } else {
            throwSyncError("Error " + responseCode);
        }
    }
    
    function onArtwork(responseCode, data) {
    	if (responseCode == 200) { 
    		Storage.setValue(podcasts[podcastsIndex][Constants.PODCAST_ID], data);
    	} else {
    		System.println(responseCode);
    	}
    	getNextEpisode();
    }
      
    // Downloads the next song to be synced
    function getNextEpisode() {
        
    	if(episodesIndex < episodes.size())
    	{ 	
    	    var progress =  episodesIndex / episodes.size().toFloat();
	        progress = (progress * 100).toNumber();
	        Media.notifySyncProgress(progress);
    	
    		if(episodesUrl[episodesIndex] != null){
    		
	            var options = {     
	           		:method => Communications.HTTP_REQUEST_METHOD_GET,
	           		:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
	               	:mediaEncoding => Media.ENCODING_MP3,
	               	:fileDownloadProgressCallback => method(:onFileProgress)
	            };
	               	
	            System.println("Downloading episode ID " + episodes[episodesIndex][Constants.EPISODE_ID] + " at " + episodesUrl[episodesIndex]);  	
				Communications.makeWebRequest(episodesUrl[episodesIndex], null, options, method(:onEpisode));	
			} else {
				episodesIndex++;
				getNextEpisode();
			}		
			
		}else{
			// All episodes downloaded, get next podcast
			podcastsIndex++;
			getNextPodcast();
		}
    }

    function onEpisode(responseCode, data) {   	
        if (responseCode == 200) {
        
	        var refId = data.getId();
	        
	        episodes[episodesIndex][Constants.EPISODE_MEDIA] = refId;
	               
	        // Fix metadata	
            var ref = new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);
            var metadata = Media.getCachedContentObj(ref).getMetadata();
            
            if(metadata.title == null || metadata.title == ""){
            	metadata.title = "(no title)";
            }     
            metadata.artist = podcasts[podcastsIndex][Constants.PODCAST_TITLE];
            Media.getCachedContentObj(ref).setMetadata(metadata);
            
            episodesIndex++;
            getNextEpisode();           
        } else {
            throwSyncError("Error " + responseCode);
        }
    }
    
    function onFileProgress(bytesTransferred, fileSize){
    
    	var episodesToDownload = settingEpisodesPerPodcast*podcasts.size();
    	var episodesDownloaded = settingEpisodesPerPodcast*podcastsIndex + episodesIndex;
    	
    	var progress = episodesDownloaded/episodesToDownload.toFloat();
    	
    	if(bytesTransferred != null && fileSize != null && fileSize != 0){
    		progress += (bytesTransferred/fileSize.toFloat())/episodesToDownload.toFloat();
    	}
    	
    	Media.notifySyncProgress((progress*100).toNumber());
    }
}
