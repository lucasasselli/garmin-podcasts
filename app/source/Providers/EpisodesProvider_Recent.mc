using Toybox.Communications;
using Toybox.Media;
using Toybox.Application.Storage;

class EpisodesProvider_Recent {

    var podcastEpisodesIterator;

    var podcastProvider;
    var podcasts = {};

    var episodes = {};

    var settingEpisodesPerPodcast;
    var settingEpisodesMax;

    var doneCallback;
    var errorCallback;

    function initialize(){
        podcastProvider = new PodcastsProviderWrapper();
    }

    function valid(displayError){
        return podcastProvider.valid(displayError);
    }

    function get(doneCallback, errorCallback){
        self.errorCallback = errorCallback;
        self.doneCallback = doneCallback;

        // Get settings
        settingEpisodesPerPodcast = Application.getApp().getProperty("settingEpisodes").toNumber();
        settingEpisodesMax = Application.getApp().getProperty("settingEpisodesMax").toNumber();

        // Get podcasts
        podcastProvider.get(method(:onPodcastGet), errorCallback);
    }

    function onPodcastGet(podcasts){
        self.podcasts = podcasts;
        podcastEpisodesIterator = new Iterator(podcasts.keys(), method(:getEpisodes), method(:getEpisodesDone));
        podcastEpisodesIterator.next();
    }

    function getEpisodes(item){
        System.println("Downloading episode list for " + podcasts[item][Constants.PODCAST_URL]);
        Communications.makeWebRequest(
            Constants.URL_FEEDPARSER_ROOT,
            {"url" => podcasts[item][Constants.PODCAST_URL], "max" => settingEpisodesPerPodcast},
            PodcastIndex.getRequestOptions(),
            method(:onEpisodes));
    }

    function onEpisodes(responseCode, data) {

        // Error
        if (responseCode != 200) {
            errorCallback.invoke("Error " + responseCode);
            return;
        }

        var items = Utils.getSafeDictKey(data, "feed");

        if(items != null){
            // Parse the episodes
            for(var i=0; i<items.size(); i++){
                var podcastId = podcastEpisodesIterator.item();
                var episode = PodcastIndex.itemToEpisode(items[i], podcastId);
                var episodeId = Utils.hash(episode[Constants.EPISODE_URL]);
                episodes.put(episodeId, episode);
            }
        }

        podcastEpisodesIterator.next();
    }

    function getEpisodesDone(){
        // Sort and trim episodes
        var keys = episodes.keys();
        var swapped;
        do {
            swapped = false;
            for(var i=0; i<keys.size()-1; i++){
                if (episodes[keys[i]][Constants.EPISODE_DATE] < episodes[keys[i+1]][Constants.EPISODE_DATE]){
                    Utils.arraySwap(keys, i, i+1);
                    swapped = true;
                }
            }
        }while(swapped);

        keys = keys.slice(settingEpisodesMax-1, keys.size());

        for(var i=0; i<keys.size()-1; i++){
            episodes.remove(keys[i]);
        }

        doneCallback.invoke(podcasts, episodes);
    }
}