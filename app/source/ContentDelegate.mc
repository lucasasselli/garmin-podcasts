using Toybox.Media;
using Toybox.Application.Storage;

class ContentDelegate extends Media.ContentDelegate {

    // Iterator for playing songs
    private var mIterator;
    
    private var saved;

    // Constructor
    function initialize() {
        ContentDelegate.initialize();
        resetContentIterator();            
        saved = StorageHelper.get(Constants.STORAGE_SAVED, []); // TODO: Reorganize
    }

    // Returns the iterator to play songs
    function getContentIterator() {
        return mIterator;
    }

    // Returns the iterator to play songs
    function resetContentIterator() {
        mIterator = new ContentIterator();
        return mIterator;
    }
    
    function onSong(refId, songEvent, playbackPosition) {
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
    }
}