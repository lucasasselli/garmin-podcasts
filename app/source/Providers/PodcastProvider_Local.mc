using Toybox.Application.Storage;

class PodcastsProvider_Local extends PodcastsProviderBase {

    function initialize(){
        PodcastsProviderBase.initialize(false);
    }

    function valid(){
        return true;
    }

    function add(podcast, doneCallback, errorCallback){
        PodcastsProviderBase.add(podcast, doneCallback, errorCallback);

        podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        podcasts.put(Utils.hash(podcast[Constants.PODCAST_URL]), podcast);
        Storage.setValue(Constants.STORAGE_SUBSCRIBED, podcasts);

        return false;
    }

    function remove(podcast, doneCallback, errorCallback){

        PodcastsProviderBase.remove(podcast, doneCallback, errorCallback);

        podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        podcasts.remove(Utils.hash(podcast[Constants.PODCAST_URL]));
        Storage.setValue(Constants.STORAGE_SUBSCRIBED, podcasts);

        // Trigger data cleanup
        Utils.purgeBadMedia();

        return false;
    }
}