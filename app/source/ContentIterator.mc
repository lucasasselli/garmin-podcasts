using Toybox.Application;
using Toybox.Math;
using Toybox.Media;

// Iterator to control the order of song playback
class ContentIterator extends Media.ContentIterator {

    // The index of the current song in playlist
    private var playlistIndex;
    
    // The refIds of the songs to play
    private var playlist;

    // Constructor
    function initialize() {
        ContentIterator.initialize();
        playlistIndex = 0;

        initializePlaylist();
    }

    // Returns the playback profile
    function getPlaybackProfile() {
        var profile = new PlaybackProfile();

        profile.playbackControls = [
           Media.PLAYBACK_CONTROL_PLAY,
           Media.PLAYBACK_CONTROL_PAUSE,
           Media.PLAYBACK_CONTROL_PREVIOUS,
           Media.PLAYBACK_CONTROL_NEXT,
           Media.PLAYBACK_CONTROL_SKIP_FORWARD,
           Media.PLAYBACK_CONTROL_SKIP_BACKWARD,
           Media.PLAYBACK_CONTROL_LIBRARY
		];

        profile.playSpeedMultipliers = [Media.PLAYBACK_SPEED_NORMAL];
        profile.attemptSkipAfterThumbsDown = true;
        profile.supportsPlaylistPreview = true;
        profile.requirePlaybackNotification = false;
        profile.playbackNotificationThreshold = 30;
        profile.skipPreviousThreshold = 4;

        return profile;
    }

    // Returns the next song, or null if there is no next song. Also increments the current
    // song index.
    function next() {
        if (playlistIndex < (playlist.size() - 1)) {
            ++playlistIndex;
            var obj = Media.getCachedContentObj(new Media.ContentRef(playlist[playlistIndex], Media.CONTENT_TYPE_AUDIO));
            return obj;
        }

        return null;
    }

    // Returns the previous song, or null if there is no previous song. Also decrements the current
    // song index.
    function previous() {
        if (playlistIndex > 0) {
            --playlistIndex;
            var obj = Media.getCachedContentObj(new Media.ContentRef(playlist[playlistIndex], Media.CONTENT_TYPE_AUDIO));
            return obj;
        }

        return null;
    }

    // Gets the current song to play
    function get() {
        var obj = null;
        if ((playlistIndex >= 0) && (playlistIndex < playlist.size())) {
            obj = Media.getCachedContentObj(new Media.ContentRef(playlist[playlistIndex], Media.CONTENT_TYPE_AUDIO));
        }

        return obj;
    }

    // Returns the next song, or null if there is no next song, without decrementing the current song index.
    function peekNext() {
        var nextIndex = playlistIndex + 1;
        if (nextIndex < playlist.size()) {
            var obj = Media.getCachedContentObj(new Media.ContentRef(playlist[nextIndex], Media.CONTENT_TYPE_AUDIO));
            return obj;
        }

        return null;
    }

    // Returns the previous song, or null if there is no previous song, without incrementing the current song index.
    function peekPrevious() {
        var previousIndex = playlistIndex - 1;
        if (previousIndex >= 0) {
            var obj = Media.getCachedContentObj(new Media.ContentRef(playlist[previousIndex], Media.CONTENT_TYPE_AUDIO));
            return obj;
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
        var tempPlaylist = StorageHelper.get(Constants.STORAGE_PLAYLIST, null);

        if (tempPlaylist == null) {
            var availableSongs = Media.getContentRefIter({:contentType => Media.CONTENT_TYPE_AUDIO});

            playlist = [];
            if (availableSongs != null) {
                var song = availableSongs.next();
                while (song != null) {
                    playlist.add(song.getId());
                    song = availableSongs.next();
                }
            }
        } else {
            playlist = new [tempPlaylist.size()];
            for (var idx = 0; idx < playlist.size(); ++idx) {
                playlist[idx] = tempPlaylist[idx];
            }
        }
    }
}
