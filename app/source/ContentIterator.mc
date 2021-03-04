using Toybox.Application;
using Toybox.Math;
using Toybox.Media;

// Iterator to control the order of song playback
class ContentIterator extends Media.ContentIterator {

    // The index of the current song in playlist
    private var playlistIndex;
    
    private var playlist;
    private var saved;

    // Constructor
    function initialize() {
        playlistIndex = 0;

        initializePlaylist();

        ContentIterator.initialize();
    }

    // Returns the playback profile
    function getPlaybackProfile() {
        var profile = new Media.PlaybackProfile();

        profile.playbackControls = [
           Media.PLAYBACK_CONTROL_NEXT,
           Media.PLAYBACK_CONTROL_PREVIOUS,
           Media.PLAYBACK_CONTROL_SKIP_FORWARD,
           Media.PLAYBACK_CONTROL_SKIP_BACKWARD,
           Media.PLAYBACK_CONTROL_LIBRARY
		];

        profile.playSpeedMultipliers = [Media.PLAYBACK_SPEED_NORMAL];
        profile.attemptSkipAfterThumbsDown = true;
        profile.supportsPlaylistPreview = true;
        profile.requirePlaybackNotification = false;
        profile.skipPreviousThreshold = 30;

        return profile;
    }

    function getAtIndex(index){
        var ref = new Media.ContentRef(playlist[index], Media.CONTENT_TYPE_AUDIO);
        var episode = Utils.findArrayField(saved, Constants.EPISODE_MEDIA, playlist[index]);
        var obj = Media.getCachedContentObj(ref);
        if(episode != null && episode[Constants.EPISODE_PROGRESS] != null){
            obj = new Media.ActiveContent(ref, obj.getMetadata(), episode[Constants.EPISODE_PROGRESS]);
        }
        
        return obj;
    }

    // Returns the next song, or null if there is no next song. Also increments the current
    // song index.
    function next() {
        if (playlistIndex < (playlist.size() - 1)) {
            ++playlistIndex;
            return getAtIndex(playlistIndex);
        }

        return null;
    }

    // Returns the previous song, or null if there is no previous song. Also decrements the current
    // song index.
    function previous() {
        if (playlistIndex > 0) {
            --playlistIndex;
            return getAtIndex(playlistIndex);
        }

        return null;
    }

    // Gets the current song to play
    function get() {
        var obj = null;
        if ((playlistIndex >= 0) && (playlistIndex < playlist.size())) {
            return getAtIndex(playlistIndex);
        }
        return null;
    }

    // Returns the next song, or null if there is no next song, without decrementing the current song index.
    function peekNext() {
        var nextIndex = playlistIndex + 1;
        if (nextIndex < playlist.size()) {
            return getAtIndex(nextIndex);
        }

        return null;
    }

    // Returns the previous song, or null if there is no previous song, without incrementing the current song index.
    function peekPrevious() {
        var previousIndex = playlistIndex - 1;
        if (previousIndex >= 0) {
            return getAtIndex(previousIndex);
        }

        return null;
    }

    // Returns if the current song can be skipped. This is controlled by the data returned by the server.
    function canSkip() {
        return true;
    }

    // Gets the songs to play. If no playlist is available then all the songs in the
    // system are played.
    function initializePlaylist() {

        saved = StorageHelper.get(Constants.STORAGE_SAVED, []);

        // Read the playlist from storage
        var tempPlaylist = StorageHelper.get(Constants.STORAGE_PLAYLIST, null);

        if (tempPlaylist == null) {
            // Add all the episodes in memory
            var episodes = Media.getContentRefIter({:contentType => Media.CONTENT_TYPE_AUDIO});
            playlist = [];
            if (episodes != null) {
                var episode = episodes.next();
                while (episode != null) {
                    playlist.add(episode.getId());
                    episode = episodes.next();
                }
            }
        } else {
            // Add the episodes in storage
            playlist = new [tempPlaylist.size()];
            for (var i = 0; i < playlist.size(); ++i) {
                playlist[i] = tempPlaylist[i];
            }
        }
    }
}
