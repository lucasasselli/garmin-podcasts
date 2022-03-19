using Toybox.Application;
using Toybox.Math;
using Toybox.Media;

// Iterator to control the order of song playback
class ContentIterator extends Media.ContentIterator {

    // The index of the current song in queue
    private var queueIndex;

    private var queue;
    private var episodes;

    // Constructor
    function initialize() {
        queueIndex = 0;

        initializeQueue();

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
        var ref = new Media.ContentRef(queue[index], Media.CONTENT_TYPE_AUDIO);
        var episode = Utils.findArrayField(episodes, Constants.EPISODE_MEDIA, queue[index]);
        var obj = Media.getCachedContentObj(ref);
        if(episode != null && episode[Constants.EPISODE_PROGRESS] != null){
            obj = new Media.ActiveContent(ref, obj.getMetadata(), episode[Constants.EPISODE_PROGRESS]);
        }

        return obj;
    }

    // Returns the next song, or null if there is no next song. Also increments the current
    // song index.
    function next() {
        if (queueIndex < (queue.size() - 1)) {
            ++queueIndex;
            return getAtIndex(queueIndex);
        }

        return null;
    }

    // Returns the previous song, or null if there is no previous song. Also decrements the current
    // song index.
    function previous() {
        if (queueIndex > 0) {
            --queueIndex;
            return getAtIndex(queueIndex);
        }

        return null;
    }

    // Gets the current song to play
    function get() {
        var obj = null;
        if ((queueIndex >= 0) && (queueIndex < queue.size())) {
            return getAtIndex(queueIndex);
        }
        return null;
    }

    // Returns the next song, or null if there is no next song, without decrementing the current song index.
    function peekNext() {
        var nextIndex = queueIndex + 1;
        if (nextIndex < queue.size()) {
            return getAtIndex(nextIndex);
        }

        return null;
    }

    // Returns the previous song, or null if there is no previous song, without incrementing the current song index.
    function peekPrevious() {
        var previousIndex = queueIndex - 1;
        if (previousIndex >= 0) {
            return getAtIndex(previousIndex);
        }

        return null;
    }

    // Returns if the current song can be skipped. This is controlled by the data returned by the server.
    function canSkip() {
        return true;
    }

    // Gets the songs to play. If no queue is available then all the songs in the
    // system are played.
    function initializeQueue() {

        var autoQueue = Application.getApp().getProperty("settingQueueAutoSelect");
        var sortDescending = Application.getApp().getProperty("settingQueueSortDescending") == 1;

        Utils.purgeBadMedia();

        episodes = (StorageHelper.get(Constants.STORAGE_EPISODES, {})).values();
        episodes = Utils.sortArrayField(episodes, Constants.EPISODE_DATE, sortDescending);

        var added = 0;
        queue = [];

        for(var i=0; i<episodes.size(); i++){
            var episode = episodes[i];
            if(episode[Constants.EPISODE_IN_QUEUE] == true || autoQueue){
                queue.add(episode[Constants.EPISODE_MEDIA]);
                added++;
            }
        }

        if(added == 0){
            for(var i=0; i<episodes.size(); i++){
                queue.add(episodes[i][Constants.EPISODE_MEDIA]);
            }
        }
    }
}
