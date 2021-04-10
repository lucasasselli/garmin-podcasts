using Toybox.Communications;
using Toybox.Media;
using Toybox.Application.Storage;

class SyncDelegate extends Communications.SyncDelegate {

    var episodes;
    var artworks;

    var downloadsIterator;

    var artworkUrl;
    var episodeUrl;
    var podcastTitle;

    var downloadErrors = [];

    function initialize() {
        SyncDelegate.initialize();
    }

    function onStartSync() {
        // Reset Manual flag
        Storage.setValue(Constants.STORAGE_MANUAL_SYNC, false);

        artworks = StorageHelper.get(Constants.STORAGE_ARTWORKS, []);

        var episodesProvider = new EpisodesProviderWrapper();
        if(episodesProvider.valid(false)){
            episodesProvider.get(method(:onEpisodes), method(:throwSyncError));
        }else{
            var service = Application.getApp().getProperty("settingPodcastService");
            switch(service){
                case PODCAST_SERVICE_LOCAL:
                throwSyncError("Error: Unknown");
                break;

                case PODCAST_SERVICE_GPODDER:
                throwSyncError(StringHelper.get(Rez.Strings.errorNoCredentials));
                break;
            }
        }
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

    function needsMedia(id){
        return (episodes[id][Constants.EPISODE_MEDIA] == null);
    }

    function needsArtwork(id){
        return (artworks.indexOf(episodes[id][Constants.EPISODE_PODCAST]) < 0);
    }

    function onEpisodes(episodes){

        self.episodes = episodes;

        var downloadEpisodes = [];
        var ids = episodes.keys();
        for(var i=0; i<ids.size(); i++){
            if(needsMedia(ids[i]) || needsArtwork(ids[i])){
                downloadEpisodes.add(ids[i]);
            }
        }

        downloadsIterator = new Iterator(downloadEpisodes, method(:downloadEpisode), method(:onDownloadEpisodesDone));
        downloadsIterator.next();
    }

    function downloadEpisode(item){
        System.println("Getting info for episode " + item);
        PodcastIndex.request(Constants.URL_PODCASTINDEX_EPISODE, {"id" => item }, method(:onInfo));
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
        downloadsIterator.next();
    }

    function downloadArtwork(){
        if(!needsArtwork(downloadsIterator.item())){
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
            var podcastId = episodes[downloadsIterator.item()][Constants.EPISODE_PODCAST];
            artworks.add(podcastId);
            Storage.setValue(Constants.STORAGE_ARTWORKS, artworks);
            Storage.setValue(Constants.ART_PREFIX + podcastId, data);
        } else {
            System.println(responseCode);
        }
        downloadMedia();
    }

    function downloadMedia(){
        if(!needsMedia(downloadsIterator.item())){
            System.println("Skipping episode " + episodeUrl);
            downloadsIterator.next();
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
            episodes[downloadsIterator.item()][Constants.EPISODE_MEDIA] = data.getId();

            var mediaObj = Utils.getSafeMedia(data.getId());
            var metadata = mediaObj.getMetadata();
            metadata.title = episodes[downloadsIterator.item()][Constants.EPISODE_TITLE];
            metadata.artist = podcastTitle;
            mediaObj.setMetadata(metadata);

            Storage.setValue(Constants.STORAGE_EPISODES, episodes);
        }else{
            downloadErrors.add(responseCode);
            System.println("Download error " + responseCode);
        }
        downloadsIterator.next();
    }

    function onDownloadEpisodesDone(){
        if(downloadErrors.size() > 0){
            throwSyncError("Error! " + downloadErrors.toString());
        }else{
            System.println("Sync done!");

            // Save episodes
            Storage.setValue(Constants.STORAGE_EPISODES, episodes);

            // Clean data
            Utils.purgeBadMedia();

            Communications.notifySyncComplete(null);
        }
    }

    function onFileProgress(bytesTransferred, fileSize){
        var progress= downloadsIterator.index()/downloadsIterator.size().toFloat();
        if(bytesTransferred != null && fileSize != null && fileSize != 0){
            progress += (bytesTransferred/fileSize.toFloat())/downloadsIterator.size().toFloat();
        }
        Communications.notifySyncProgress((progress*100).toNumber());
    }
}