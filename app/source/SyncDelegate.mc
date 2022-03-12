using Toybox.Communications;
using Toybox.Media;
using Toybox.Application.Storage;

class SyncDelegate extends Communications.SyncDelegate {

    var episodes;
    var podcasts;
    var artworks;

    var downloadsIterator;

    var downloadErrors = [];

    function initialize() {
        SyncDelegate.initialize();
    }

    function onStartSync() {
        // Reset Manual flag
        Storage.setValue(Constants.STORAGE_MANUAL_SYNC, false);

        self.episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
        self.podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        self.artworks = StorageHelper.get(Constants.STORAGE_ARTWORKS, []);

        var downloadEpisodes = [];

        var ids = episodes.keys();
        for(var i=0; i<ids.size(); i++){
            if(needsMedia(ids[i]) || needsArtwork(ids[i])){
                downloadEpisodes.add(ids[i]);
            }
        }

        downloadsIterator = new CompactLib.Utils.Iterator(downloadEpisodes, method(:downloadEpisode), method(:onDownloadEpisodesDone));
        downloadsIterator.next();
    }

    function isSyncNeeded() {
        return true;
    }

    function onStopSync() {
        Log.debug("Sync cancelled!");
        throwSyncError(null);
    }

    function throwSyncError(msg){
        Log.debug(msg);
        Communications.cancelAllRequests();

        // Clean media
        Utils.purgeBadMedia();
        Communications.notifySyncComplete(msg);
    }

    function needsMedia(id){
        return (episodes[id][Constants.EPISODE_MEDIA] == null);
    }

    function needsArtwork(id){
        return (artworks.indexOf(episodes[id][Constants.EPISODE_PODCAST]) < 0);
    }

    function downloadEpisode(item){
        downloadArtwork();
    }

    function downloadArtwork(){

        var episodeId = downloadsIterator.item();
        var podcastId = episodes[episodeId][Constants.EPISODE_PODCAST];
        var artworkUrl = podcasts[podcastId][Constants.PODCAST_ARTWORK];


        if(!needsArtwork(downloadsIterator.item())){
            Log.debug("Skipping artwork " + artworkUrl);
            getMediaInfo();
        }else{
            Log.debug("Downloading artwork " + artworkUrl + " for " + podcastId);
            var options = {
                :maxWidth  => Constants.IMAGE_SIZE,
                :maxHeight => Constants.IMAGE_SIZE,
                :fileDownloadProgressCallback => method(:onFileProgress)
            };
            Communications.makeImageRequest(artworkUrl, null, options, method(:onArtwork));
        }
    }

    function onArtwork(responseCode, data) {

        var episodeId = downloadsIterator.item();
        var podcastId = episodes[episodeId][Constants.EPISODE_PODCAST];

        if (responseCode == 200) {
            artworks.add(podcastId);
            Storage.setValue(Constants.STORAGE_ARTWORKS, artworks);
            Storage.setValue(Constants.ART_PREFIX + podcastId, data);
        } else {
            Log.debug(responseCode);
        }
        getMediaInfo();
    }

    function getMediaInfo(){
        var episodeId = downloadsIterator.item();
        var podcastId = episodes[episodeId][Constants.EPISODE_PODCAST];
        var podcastUrl = podcasts[podcastId][Constants.PODCAST_URL];

        var mediaUrlRequest = new CompactLib.Utils.CompactRequest(null);
        mediaUrlRequest.request(
            Constants.URL_FEEDPARSER_ROOT,
            {"feedUrl" => podcastUrl, "episodeId" => episodeId},
            method(:onMediaInfo),
            episodeId);
    }

    function onMediaInfo(responseCode, data, context){
        if (responseCode == 200) {
            var episodeId = downloadsIterator.item();
            episodes[episodeId][Constants.EPISODE_TITLE] = data.get("title");
            episodes[episodeId][Constants.EPISODE_DURATION] = data.get("duration");

            // FIXME: Likely never null!
            var url = data.get("url");
            if(url != null){
                downloadMedia(url);
                return;
            }else{
            }
        }
        Log.debug("Unable to get the url for " + context);
        downloadsIterator.next();
    }

    function downloadMedia(url){

        var episodeId = downloadsIterator.item();
        var podcastId = episodes[episodeId][Constants.EPISODE_PODCAST];
        var podcastUrl = podcasts[podcastId][Constants.PODCAST_URL];

        if(!needsMedia(episodeId)){
            Log.debug("Skipping episode " + url);
            downloadsIterator.next();
        }else{
            var format = (url.substring(url.length()-3, url.length())).toLower();
            var encoding;
            switch (format) {

                case "mp3":
                    encoding = Media.ENCODING_MP3;
                    break;

                case "m4a":
                    encoding = Media.ENCODING_M4A;
                    break;

                case "wav":
                    encoding = Media.ENCODING_WAV;
                    break;

                default:
                    encoding = Media.ENCODING_MP3;
                    format = "mp3";
                    break;
            }

            Log.debug("Downloading " + format + " episode " + url);
            var options = {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
                :mediaEncoding => encoding,
                :fileDownloadProgressCallback => method(:onFileProgress)
            };
            Communications.makeWebRequest(url, null, options, method(:onMedia));
        }
    }

    function onMedia(responseCode, data) {

        var episodeId = downloadsIterator.item();
        var podcastId = episodes[episodeId][Constants.EPISODE_PODCAST];

        if (responseCode == 200) {
            episodes[downloadsIterator.item()][Constants.EPISODE_MEDIA] = data.getId();

            var mediaObj = Utils.getSafeMedia(data.getId());
            var metadata = mediaObj.getMetadata();

            metadata.title = episodes[episodeId][Constants.EPISODE_TITLE];
            metadata.artist = podcasts[podcastId][Constants.PODCAST_TITLE];

            mediaObj.setMetadata(metadata);

            Storage.setValue(Constants.STORAGE_EPISODES, episodes);
        }else{
            downloadErrors.add(responseCode);
            Log.debug("Download error " + responseCode);
        }
        downloadsIterator.next();
    }

    function onDownloadEpisodesDone(){
        if(downloadErrors.size() > 0){
            throwSyncError("Error! " + downloadErrors.toString());
        }else{
            Log.debug("Sync done!");

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