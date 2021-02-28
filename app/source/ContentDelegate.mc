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

        // Handle artwork
        if(songEvent == Media.SONG_EVENT_START){
            var saved = StorageHelper.get(Constants.STORAGE_SAVED, []);
            var artwork = null;
            var episode = Utils.findArrayField(saved, Constants.EPISODE_MEDIA, refId);           	
            if(episode != null){ 
                artwork = Storage.getValue(episode[Constants.EPISODE_PODCAST]);
            }
            Media.setAlbumArt(artwork);
        }

        // Handle progress...
        if(songEvent == Media.SONG_EVENT_STOP || songEvent == Media.SONG_EVENT_PAUSE){
            // Stop/Pause
            var now = new [Constants.NOWPLAYING_DATA_SIZE];
            now[Constants.NOWPLAYING_MEDIA]    = refId;
            now[Constants.NOWPLAYING_PROGRESS] = playbackPosition;
            Storage.setValue(Constants.STORAGE_NOWPLAYING, now);
            System.println("Progress saved...");
        }else{
            Storage.setValue(Constants.STORAGE_NOWPLAYING, null);
            System.println("Progress cleared...");
        }
    }
}