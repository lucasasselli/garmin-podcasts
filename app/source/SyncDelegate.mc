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
    
    function onStartSync() {
    
    	podcasts = Utils.getSafeStorageArray(Constants.STORAGE_SUBSCRIBED);
        podcastsIndex = 0;
        
        episodes = [];
        episodesUrl = [];
	    episodesIndex = 0;
        
    	saved = Utils.getSafeStorageArray(Constants.STORAGE_SAVED);
    	
    	// Get settings
    	settingEpisodesPerPodcast = Application.getApp().getProperty("settingEpisodes").toNumber();

		// Start sync
    	getNextPodcast();
    }

    function isSyncNeeded() {
        return true;
    }

    function onStopSync() {
        throwSyncError(null);
    }
    
    function throwSyncError(msg){
		System.println("Sync Error: " + msg);
    	Communications.cancelAllRequests();
    	Communications.notifySyncComplete(msg);
    }
    
    function cleanMedia(){
    	for(var i=0; i<saved.size(); i++){
			var x = Utils.findArrayField(episodes, Constants.EPISODE_ID, saved[i][Constants.EPISODE_ID]);
    		if(x == null){  		
    			System.println("Episode " + saved[i][Constants.EPISODE_ID] + " no longer needed!");
    			    			
            	var mediaObj = Utils.getSafeMedia(saved[i][Constants.EPISODE_MEDIA]);
				if(mediaObj != null){
					Media.deleteCachedItem(mediaObj.getContentRef());
				}
    		}
    	}
    }
    
    function getNextPodcast(){		
    	if(podcastsIndex < podcasts.size()){	
			var podcastId = podcasts[podcastsIndex][Constants.PODCAST_ID];
			System.println("Downloading podcast " + podcastId);
    		Remote.request(Constants.URL_EPISODES, {"id" => podcastId, "max" => settingEpisodesPerPodcast}, method(:onPodcast));
    	} else {
			// All episode info ready, remove old episodes
			cleanMedia();		
			getNextEpisode();
		}
    }
    
    function onPodcast(responseCode, data) {
        if (responseCode == 200) { 
        	var items = Utils.getSafeDictKey(data, "items");
        	var artworkUrl = null;
        	
        	if(items != null){
				for(var i=0; i<items.size(); i++){
				
					var episode = new [Constants.EPISODE_DATA_SIZE];
					
					if(items[0]["feedImage"] != null){
						artworkUrl = items[0]["feedImage"];
					}
		    				
					episode[Constants.EPISODE_ID] = items[i]["id"];
					episode[Constants.EPISODE_PODCAST] = podcasts[podcastsIndex][Constants.PODCAST_ID];
					
					var match = Utils.findArrayField(saved, Constants.EPISODE_ID, episode[Constants.EPISODE_ID]);
					if(match != null){
						episode[Constants.EPISODE_MEDIA]= match[Constants.EPISODE_MEDIA];
					}
            		var mediaObj = Utils.getSafeMedia(episode[Constants.EPISODE_MEDIA]);
		
		    		if(mediaObj == null){				
						episodes.add(episode);	
						episodesUrl.add(items[i]["enclosureUrl"]);
		    		}else{
						episodes.add(episode);	
		    			episodesUrl.add(null);
		    			System.println("Episode " + episode[Constants.EPISODE_ID] + " already downloaded!");
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
					podcastsIndex++;
					getNextPodcast();
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
		podcastsIndex++;
		getNextPodcast();
    }
      
    function getNextEpisode() {
    	if(episodesIndex < episodes.size())
    	{ 	
    		if(episodesUrl[episodesIndex] != null){
    		
	            var options = {     
	           		:method => Communications.HTTP_REQUEST_METHOD_GET,
	           		:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
	               	:mediaEncoding => Media.ENCODING_MP3,
	               	:fileDownloadProgressCallback => method(:onFileProgress)
	            };
	               	
	        	var episodeId = episodes[episodesIndex][Constants.EPISODE_ID];
				var episodeUrl = episodesUrl[episodesIndex];
				System.println("Downloading episode " + episodeId + " at " + episodeUrl);  	
				Communications.makeWebRequest(episodeUrl, null, options, method(:onEpisode));	
			} else {
				// If url is null the episode wqas already downloaded
				episodesIndex++;
				getNextEpisode();
			}		
		}else{
			// All episodes downloaded, get next podcast
			System.println("Sync complete!");
			Communications.notifySyncComplete(null);		
		}
    }

    function onEpisode(responseCode, data) {   	
        if (responseCode == 200) {
            var ref = new Media.ContentRef(data.getId(), Media.CONTENT_TYPE_AUDIO);
            var metadata = Media.getCachedContentObj(ref).getMetadata();

	        episodes[episodesIndex][Constants.EPISODE_MEDIA] = data.getId();
            
			// Fix metadata
			var podcast = Utils.findArrayField(podcasts, Constants.PODCAST_ID, episodes[episodesIndex][Constants.EPISODE_PODCAST]);
            if(metadata.title == null || metadata.title == ""){
				// Title is empty
            	metadata.title = WatchUi.loadResource(Rez.Strings.emptyTitle);
            }     
            metadata.artist = podcast[Constants.PODCAST_TITLE];
            Media.getCachedContentObj(ref).setMetadata(metadata);
            
			// Update storage
			Storage.setValue(Constants.STORAGE_SAVED, episodes);		

            episodesIndex++;
            getNextEpisode();           
        } else {
            throwSyncError("Error " + responseCode);
        }
    }
    
    function onFileProgress(bytesTransferred, fileSize){
    	var progress= episodesIndex/episodes.size().toFloat();
    	if(bytesTransferred != null && fileSize != null && fileSize != 0){
    		progress += (bytesTransferred/fileSize.toFloat())/episodes.size().toFloat();
    	}
		Communications.notifySyncProgress((progress*100).toNumber());
    }
}
