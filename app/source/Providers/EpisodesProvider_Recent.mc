using Toybox.Communications;
using Toybox.Media;
using Toybox.Application.Storage;

class EpisodesProvider_Recent {

    var podcastEpisodesIterator;

    var podcastProvider;
    var podcasts = [];

    var episodes = [];

	var settingEpisodesPerPodcast;
	var settingEpisodesMax;

    var doneCallback;
    var errorCallback;

    function initialize(){
        podcastProvider = new PodcastsProviderWrapper();
    }

    function valid(){
        return podcastProvider.valid();
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
        podcastEpisodesIterator = new Iterator(podcasts, method(:getEpisodes), method(:getEpisodesDone));
        podcastEpisodesIterator.next();
    }

    function getEpisodes(item){
		System.println("Downloading episode list for " + item[Constants.PODCAST_ID]);
    	PodcastIndex.request(Constants.URL_PODCASTINDEX_EPISODES, {"id" => item[Constants.PODCAST_ID], "max" => settingEpisodesPerPodcast}, method(:onEpisodes));
    }

    function onEpisodes(responseCode, data) {

        // Error
        if (responseCode != 200) { 
            errorCallback.invoke("Error " + responseCode);
            return;
        }

        var items = Utils.getSafeDictKey(data, "items");
        if(items != null && items.size() > 0){
            // Parse the episodes
            for(var i=0; i<items.size(); i++){
                var episode = PodcastIndex.itemToEpisode(items[i], podcastEpisodesIterator.item());
                episodes.add(episode);	
            }
        }

        podcastEpisodesIterator.next();
    }

    function getEpisodesDone(){
        // Sort and trim episodes
        var swapped;
        do {
            swapped = false;
            for(var i=0; i<episodes.size()-1; i++){
                if (episodes[i][Constants.EPISODE_DATE] < episodes[i+1][Constants.EPISODE_DATE]){
                    Utils.arraySwap(episodes, i, i+1);
                    swapped = true;
                }
            }
        }while(swapped);
        episodes = episodes.slice(0, settingEpisodesMax);
        doneCallback.invoke(episodes);
    }
}