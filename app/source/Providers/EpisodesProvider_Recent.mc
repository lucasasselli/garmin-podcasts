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
        var podcastEpisodesRequest = new CompactLib.Utils.CompactRequest(null);
        podcastEpisodesRequest.request(
            Constants.URL_FEEDPARSER_ROOT,
            {"feedUrl" => podcasts[item][Constants.PODCAST_URL], "max" => settingEpisodesPerPodcast},
            method(:onEpisodes),
            item);
    }

    function onEpisodes(responseCode, data, context) {
        if (responseCode == 200) {
            var items = Utils.getSafeDictKey(data, "feed");
            if(items != null){
                // Parse the episodes
                for(var i=0; i<items.size(); i++){
                    var podcastId = podcastEpisodesIterator.item();
                    var episode = Remote.itemToEpisode(items[i], podcastId);
                    episodes.put(Remote.genEpisodeId(episode), episode);
                }
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