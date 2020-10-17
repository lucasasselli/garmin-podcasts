using Toybox.Media;
using Toybox.Application.Storage;

// The content delegate to handle actions from the media player
class ContentDelegate extends Media.ContentDelegate {

        // Iterator for playing songs
        private var mIterator;
        
        private var saved;

        // Constructor
        function initialize() {
            ContentDelegate.initialize();
            resetContentIterator();            
            saved = Utils.getSafeStorageArray(Constants.STORAGE_SAVED);
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
        
        // Helper function to get the name of a song for reporting that certain functions were called
        function getSongName(refId) {
            var song = Media.getCachedContentObj(new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO));
            return song.getMetadata().title;
        }
}