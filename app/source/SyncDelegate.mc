using Toybox.Communications;
using Toybox.Media;
using Toybox.Application.Storage;

class SyncDelegate extends Communications.SyncDelegate {

    var episodes = [];
    var artworks;

    var episodesIterator;

    var artworkUrl;
    var episodeUrl;
    var podcastTitle;

    var downloadErrors = [];

    function initialize() {
        SyncDelegate.initialize();
    }
    
    function onStartSync() {
        artworks = StorageHelper.get(Constants.STORAGE_ARTWORKS, []);

        var episodesProvider = new EpisodesProviderWrapper();
        episodesProvider.get(method(:onEpisodes), method(:throwSyncError));
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

        // Clean media
        Utils.purgeBadMedia();
    }

    function needsMedia(episode){
        return (episode[Constants.EPISODE_MEDIA] == null);
    }

    function needsArtwork(episode){
        return (artworks.indexOf(episode[Constants.EPISODE_PODCAST]) < 0);
    }

    function onEpisodes(episodes){

        self.episodes = episodes;

        var downloadEpisodes = [];
        for(var i=0; i<episodes.size(); i++){
            if(needsMedia(episodes[i]) || needsArtwork(episodes[i])){
                downloadEpisodes.add(episodes[i]);
            }
        }

        episodesIterator = new Iterator(downloadEpisodes, method(:downloadEpisode), method(:onDownloadEpisodesDone));
        episodesIterator.next();
    }

    function downloadEpisode(item){
        System.println("Getting info for episode " + item[Constants.EPISODE_ID]);
    	PodcastIndex.request(Constants.URL_PODCASTINDEX_EPISODE, {"id" => item[Constants.EPISODE_ID] }, method(:onInfo));
    }

    function onInfo(responseCode, data) {
        if (responseCode == 200) {
	       	var episode = Utils.getSafeDictKey(data, "episode");
	       	if(episode != null){
                artworkUrl = episode["feedImage"];
                podcastTitle = episode["feedTitle"];
                episodeUrl = episode["enclosureUrl"];
                downloadArtwork();
                return;
	       	}
        }else{
            downloadErrors.add(responseCode);
            System.println("Info error " + responseCode);
        }
        episodesIterator.next();
    }

    function downloadArtwork(){
        if(!needsArtwork(episodesIterator.item())){
            System.println("Skipping artwork " + artworkUrl);
            downloadMedia();
        }else{
            System.println("Downloading artwork " + artworkUrl);
            var options = {
                :maxWidth  => Constants.IMAGE_SIZE,
                :maxHeight => Constants.IMAGE_SIZE,
                :fileDownloadProgressCallback => method(:onFileProgress)
            };
            Communications.makeImageRequest(artworkUrl, null, options, method(:onArtwork));
        }
    }

    function onArtwork(responseCode, data) {
        if (responseCode == 200) { 
            artworks.add(episodesIterator.item()[Constants.EPISODE_PODCAST]);
            Storage.setValue(Constants.STORAGE_ARTWORKS, artworks);
            Storage.setValue(Constants.ART_PREFIX + episodesIterator.item()[Constants.EPISODE_PODCAST], data);
        } else {
            System.println(responseCode);
        }
        downloadMedia();
    }

    function downloadMedia(){
        if(!needsMedia(episodesIterator.item())){
            System.println("Skipping episode " + episodeUrl);
            episodesIterator.next();
        }else{
            System.println("Downloading episode " + episodeUrl);
            var options = {     
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
                :mediaEncoding => Media.ENCODING_MP3,
                :fileDownloadProgressCallback => method(:onFileProgress)
            };
            Communications.makeWebRequest(episodeUrl, null, options, method(:onMedia));    
        }
    }

    function onMedia(responseCode, data) {       
        if (responseCode == 200) {

            var episode = Utils.findArrayField(episodes, Constants.EPISODE_ID, episodesIterator.item()[Constants.EPISODE_ID]);
            episode[Constants.EPISODE_MEDIA] = data.getId();

            var mediaObj = Utils.getSafeMedia(data.getId());
            var metadata = mediaObj.getMetadata();
            metadata.title = episode[Constants.EPISODE_TITLE];
            metadata.artist = podcastTitle;
            mediaObj.setMetadata(metadata);

            Storage.setValue(Constants.STORAGE_SAVED, episodes);        
        }else{
            downloadErrors.add(responseCode);
            System.println("Download error " + responseCode);
        }
        episodesIterator.next();
    }

    function onDownloadEpisodesDone(){
        if(downloadErrors.size() > 0){
            throwSyncError("Error! " + downloadErrors.toString());
        }else{
            System.println("Sync done!");
            Storage.setValue(Constants.STORAGE_SAVED, episodes);        
            Utils.purgeBadMedia();
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