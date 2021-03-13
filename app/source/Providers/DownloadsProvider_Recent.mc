using Toybox.Communications;
using Toybox.Media;
using Toybox.Application.Storage;

class DownloadsProvider_Recent {

    var podcastEpisodesIterator;

    var podcastProvider;
    var podcasts = [];

    var downloadEpisodes = [];

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
        podcastProvider.getPodcasts(method(:onPodcastGet), errorCallback);
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

            // // Get the podcast artwork from one of the episodes
            // var artworkUrl = items[0]["feedImage"];
            // if(Storage.getValue(Constants.ART_PREFIX + podcasts[podcastEpisodesIterator.index()][Constants.PODCAST_ID]) == null){
            //     artworkUrls.add(artworkUrl);
            // }else{
            //     artworkUrls.add(null);
            // }

            // Parse the episodes
            for(var i=0; i<items.size(); i++){
                var downloadItem = PodcastIndex.itemToDownload(items[i], podcastEpisodesIterator.item());
                downloadEpisodes.add(downloadItem);	
            }
        }

        podcastEpisodesIterator.next();
    }

    function getEpisodesDone(){
        // Sort and trim episodes
        var swapped;
        do {
            swapped = false;
            for(var i=0; i<downloadEpisodes.size()-1; i++){
                if (downloadEpisodes[i][Constants.DOWNLOAD_DATA][Constants.EPISODE_DATE] < downloadEpisodes[i][Constants.DOWNLOAD_DATA][Constants.EPISODE_DATE]){
                    Utils.arraySwap(downloadEpisodes, i, i+1);
                    swapped = true;
                }
            }
        }while(swapped);
        downloadEpisodes = downloadEpisodes.slice(0, settingEpisodesMax);
        doneCallback.invoke(downloadEpisodes);
    }
}