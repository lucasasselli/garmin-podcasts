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

        var episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
        var id = null;
        for(var i=0; i<episodes.size(); i++){
            if(episodes.values()[i][Constants.EPISODE_MEDIA] == refId){
                id = episodes.keys()[i];
                break;
            }
        }

        // Handle artwork
        if(songEvent == Media.SONG_EVENT_START){
            var artwork = null;
            if(id != null){
                artwork = Storage.getValue(Constants.ART_PREFIX + episodes[id][Constants.EPISODE_PODCAST]);
            }
            Media.setAlbumArt(artwork);
        }

        // Handle progress...
        if(songEvent != Media.SONG_EVENT_SKIP_PREVIOUS){
            if(id != null){
                var progress = episodes[id][Constants.EPISODE_PROGRESS];
                if(playbackPosition > 0){
                    episodes[id][Constants.EPISODE_PROGRESS] = playbackPosition;
                    Storage.setValue(Constants.STORAGE_EPISODES, episodes);
                    Log.debug("Progress saved @ " + playbackPosition);
                }
            }
        }
    }
}