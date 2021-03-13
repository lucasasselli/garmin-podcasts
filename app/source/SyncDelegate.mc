using Toybox.Communications;
using Toybox.Media;
using Toybox.Application.Storage;

class SyncDelegate extends Communications.SyncDelegate {

    var downloadsProvider;
    var downloadsIterator;
    var downloads;

    var saved;
    var artworks;
    var downloadErrors = [];

    function initialize() {
        SyncDelegate.initialize();
        downloadsProvider = new DownloadsProviderWrapper();
    }
    
    function onStartSync() {
        downloadErrors = [];
        saved = StorageHelper.get(Constants.STORAGE_SAVED, []);
        artworks = StorageHelper.get(Constants.STORAGE_ARTWORKS, []);
        downloadsProvider.get(method(:onDownloads), method(:throwSyncError));
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

    function onDownloads(downloads){
        self.downloads = downloads;
        downloadsIterator = new Iterator(downloads, method(:download), method(:onDownloadsDone));
        downloadsIterator.next();
    }

    function download(item){
        var url = item[Constants.DOWNLOAD_URL];
        if(item[Constants.DOWNLOAD_TYPE] == Constants.DOWNLOAD_TYPE_ARTWORK){
            // Artwork
            if(artworks.indexOf(item[Constants.DOWNLOAD_DATA]) >= 0){
                System.println("Skipping artwork " + url);
                downloadsIterator.next();
                return;
            }
            System.println("Downloading artwork " + url);
            var options = {
                :maxWidth  => Constants.IMAGE_SIZE,
                :maxHeight => Constants.IMAGE_SIZE,
                :fileDownloadProgressCallback => method(:onFileProgress)
            };
            Communications.makeImageRequest(url, null, options, method(:onArtwork));
        }else{
            // Episode
            if(Utils.findArrayField(saved, Constants.EPISODE_ID, item[Constants.DOWNLOAD_DATA][Constants.EPISODE_ID]) != null){
                System.println("Skipping episode " + url);
                downloadsIterator.next();
                return;
            }
            System.println("Downloading episode " + url);
            var options = {     
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
                :mediaEncoding => Media.ENCODING_MP3,
                :fileDownloadProgressCallback => method(:onFileProgress)
            };
            Communications.makeWebRequest(url, null, options, method(:onEpisode));    
        }
    }

    function onArtwork(responseCode, data) {
        if (responseCode == 200) { 
            artworks.add(downloadsIterator.item()[Constants.DOWNLOAD_DATA]);
            Storage.setValue(Constants.STORAGE_ARTWORKS, artworks);
            Storage.setValue(Constants.ART_PREFIX + downloadsIterator.item()[Constants.DOWNLOAD_DATA], data);
        } else {
            System.println(responseCode);
        }
        downloadsIterator.next();
    }

    function onEpisode(responseCode, data) {       
        if (responseCode == 200) {
            var episode = downloadsIterator.item()[Constants.DOWNLOAD_DATA];
            episode[Constants.EPISODE_MEDIA] = data.getId();
            saved.add(episode);
            Storage.setValue(Constants.STORAGE_SAVED, saved);        
        }else{
            downloadErrors.add(responseCode);
            System.println("Download error " + responseCode);
        }
        downloadsIterator.next();
    }

    function onDownloadsDone(){

        Storage.setValue(Constants.STORAGE_DOWNLOADS, []);

        if(downloadErrors.size() > 0){
            throwSyncError("Error! " + downloadErrors.toString());
        }else{
            System.println("Sync done!");
            Communications.notifySyncComplete(null);
        }

        // Clean media
        Utils.purgeBadMedia();
    }

    function onFileProgress(bytesTransferred, fileSize){
        var progress= downloadsIterator.index()/downloadsIterator.size().toFloat();
        if(bytesTransferred != null && fileSize != null && fileSize != 0){
            progress += (bytesTransferred/fileSize.toFloat())/downloadsIterator.size().toFloat();
        }
        Communications.notifySyncProgress((progress*100).toNumber());
    }
}