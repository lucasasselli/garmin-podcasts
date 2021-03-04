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
        var index = null;
        for(var i=0; i<saved.size(); i++){
            if(saved[i][Constants.EPISODE_MEDIA] == refId){
                index = i;
                break;
            }
        }

        // Handle artwork
        if(songEvent == Media.SONG_EVENT_START){
            var artwork = null;
            if(index != null){
                artwork = Storage.getValue(Constants.ART_PREFIX + saved[index][Constants.EPISODE_PODCAST]);
            }
            Media.setAlbumArt(artwork);
        }

        // Handle progress...
        if(songEvent != Media.SONG_EVENT_SKIP_PREVIOUS){
            if(index != null){
                var progress = saved[index][Constants.EPISODE_PROGRESS];
                if(playbackPosition > 0){
                    saved[index][Constants.EPISODE_PROGRESS] = playbackPosition;
                    Storage.setValue(Constants.STORAGE_SAVED, saved);
                    System.println("Progress saved @ " + playbackPosition);
                }
            }
        }
    }
}