using Toybox.Communications;
using Toybox.Media;
using Toybox.Application.Storage;

class SyncDelegate extends Communications.SyncDelegate {

	var dataHelper;
	var artworkIterator;
	var episodesIterator;

    var episodeErrors;

    function initialize() {
        SyncDelegate.initialize();

		dataHelper = new DataHelper(method(:onEpisodeList), method(:throwSyncError));
    }
    
    function onStartSync() {
        episodeErrors = 0;
		dataHelper.start();
    }

    function isSyncNeeded() {
        return true;
    }

    function onStopSync() {
        throwSyncError(null);
    }
    
    function throwSyncError(msg){
		System.println(msg);
    	Communications.cancelAllRequests();
    	Communications.notifySyncComplete(msg);
    }

	function onEpisodeList(){
		artworkIterator = new Iterator(dataHelper.artworkUrls, method(:getArtworks), method(:getArtworksDone));
		artworkIterator.next();
	}

	function getArtworks(item){
		if(item != null){
		System.println("Downloading " + item);  	
		Communications.makeImageRequest(
			item,
			null,
			{
				:maxWidth  => 64,
				:maxHeight => 64
			},
			method(:onArtwork));
		}else{
			artworkIterator.next();
		}
	}

    function onArtwork(responseCode, data) {
    	if (responseCode == 200) { 
    		Storage.setValue(dataHelper.podcasts[artworkIterator.index()][Constants.PODCAST_ID], data);
    	} else {
    		System.println(responseCode);
    	}
		artworkIterator.next();
    }

	function getArtworksDone(){
		episodesIterator = new Iterator(dataHelper.episodesUrl, method(:getEpisodes), method(:getEpisodesDone));
		episodesIterator.next();
	}

	function getEpisodes(item){
		if(item != null){
			var options = {     
				:method => Communications.HTTP_REQUEST_METHOD_GET,
				:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
				:mediaEncoding => Media.ENCODING_MP3,
				:fileDownloadProgressCallback => method(:onFileProgress)
			};
			System.println("Downloading " + item);  	
			Communications.makeWebRequest(item, null, options, method(:onEpisode));	
		}else{
			episodesIterator.next();
		}
    }

    function onEpisode(responseCode, data) {   	
        if (responseCode == 200) {
            var ref = new Media.ContentRef(data.getId(), Media.CONTENT_TYPE_AUDIO);
            var metadata = Media.getCachedContentObj(ref).getMetadata();

	        dataHelper.episodes[episodesIterator.index()][Constants.EPISODE_MEDIA] = data.getId();
            
			// Fix metadata
			var podcast = Utils.findArrayField(dataHelper.podcasts, Constants.PODCAST_ID, dataHelper.episodes[episodesIterator.index()][Constants.EPISODE_PODCAST]);
            metadata.title = dataHelper.episodes[episodesIterator.index()][Constants.EPISODE_TITLE];
            metadata.artist = podcast[Constants.PODCAST_TITLE];
            Media.getCachedContentObj(ref).setMetadata(metadata);
            
			// Update storage
			Storage.setValue(Constants.STORAGE_SAVED, dataHelper.episodes);		
        }else{
            episodeErrors++;
            System.println("Download error " + responseCode);
        }
		episodesIterator.next();
    }

	function getEpisodesDone(){
        if(episodeErrors > 0){
            throwSyncError(episodeErrors + " failed"); // TODO
        }else{
            Communications.notifySyncComplete(null);
        }
	}
    
    function onFileProgress(bytesTransferred, fileSize){
    	var progress= episodesIterator.index()/episodesIterator.size().toFloat();
    	if(bytesTransferred != null && fileSize != null && fileSize != 0){
    		progress += (bytesTransferred/fileSize.toFloat())/episodesIterator.size().toFloat();
    	}
		Communications.notifySyncProgress((progress*100).toNumber());
    }
}