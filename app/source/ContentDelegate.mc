using Toybox.Media;
using Toybox.Application.Storage;

class ContentDelegate extends Media.ContentDelegate {

    // Iterator for playing songs
    private var iterator;
    
    // Constructor
    function initialize() {
        ContentDelegate.initialize();
        resetContentIterator();            
    }

    // Returns the iterator to play songs
    function getContentIterator() {
        return iterator;
    }

    // Returns the iterator to play songs
    function resetContentIterator() {
        iterator = new ContentIterator();
        return iterator;
    }
    
    function onSong(refId, songEvent, playbackPosition) {

        var saved = StorageHelper.get(Constants.STORAGE_SAVED, []);

        // Start
        if(songEvent == Media.SONG_EVENT_START){
            var episode = Utils.findArrayField(saved, Constants.EPISODE_MEDIA, refId);           	
            if(episode == null){ 
                return;
            }
            var artwork = Storage.getValue(episode[Constants.EPISODE_PODCAST]);
            if(artwork == null){ 
                return;
            }
            Media.setAlbumArt(artwork);
        }

        // Start/Stop
        if(songEvent == Media.SONG_EVENT_STOP || songEvent == Media.SONG_EVENT_PAUSE){
            // Save now playing item
            var now = new [Constants.NOWPLAYING_DATA_SIZE];
            now[Constants.NOWPLAYING_MEDIA] = refId;
            now[Constants.NOWPLAYING_PROGRESS] = playbackPosition;
            Storage.setValue(Constants.STORAGE_NOWPLAYING, now);
        }

        if(songEvent == Media.SONG_EVENT_START){
            // Clear now playing item
            Storage.setValue(Constants.STORAGE_NOWPLAYING, null);
        }

        if(songEvent == Media.SONG_EVENT_COMPLETE){
            // Clear now playing item
            Storage.setValue(Constants.STORAGE_NOWPLAYING, null);
        }
    }
}