using Toybox.Communications;
using Toybox.Media;
using Toybox.Application.Storage;

class DataHelper {

    var podcastInfoIterator;
    var podcastEpisodesIterator;

    var podcasts = [];
    var episodes = [];
    var episodesUrl = [];
    var artworkUrls = [];

    var saved;
    
	var settingEpisodesPerPodcast;

    var doneCallback;
    var errorCallback;

    function initialize(doneCallback, errorCallback){
        self.errorCallback = errorCallback;
        self.doneCallback = doneCallback;

        // Get episodes already saved
    	saved = StorageHelper.get(Constants.STORAGE_SAVED, []);

        // Get settings
    	settingEpisodesPerPodcast = Application.getApp().getProperty("settingEpisodes").toNumber();
    }


    function start(){
    	var gpodderMode = Application.getApp().getProperty("settingGpodderEnable");
        if(gpodderMode){
            // Get podcast list from server
            getPodcasts();
        }else{
            // Get episodes for the saved podcasts
    	    podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, []);
            getEpisodesStart();
        }
    }

    function getPodcasts(){

    }

    function getEpisodesStart(){
        podcastEpisodesIterator = new Iterator(podcasts, method(:getEpisodes), method(:getEpisodesDone));
        podcastEpisodesIterator.next();
    }

    function getEpisodes(item){
		System.println("Downloading episode list for " + item[Constants.PODCAST_ID]);
    	PodcastIndex.request(Constants.URL_EPISODES, {"id" => item[Constants.PODCAST_ID], "max" => settingEpisodesPerPodcast}, method(:onEpisodes));
    }

    function onEpisodes(responseCode, data) {
        if (responseCode == 200) { 
        	var items = Utils.getSafeDictKey(data, "items");
        	if(items != null && items.size() > 0){

                // Get the podcast artwork from one of the episodes
                var artworkUrl = items[0]["feedImage"];
                if(Storage.getValue(podcasts[podcastEpisodesIterator.index()][Constants.PODCAST_ID]) == null){
                    artworkUrls.add(artworkUrl);
                }else{
                    artworkUrls.add(null);
                }

                // Parse the episodes
				for(var i=0; i<items.size(); i++){

                    var episodeUrl = items[i]["enclosureUrl"];

					var episode = new [Constants.EPISODE_DATA_SIZE];
					episode[Constants.EPISODE_ID] = items[i]["id"];
					episode[Constants.EPISODE_PODCAST] = podcastEpisodesIterator.item()[Constants.PODCAST_ID];
                    
                    // Check if the media is already available
					var match = Utils.findArrayField(saved, Constants.EPISODE_ID, episode[Constants.EPISODE_ID]);
					if(match != null){
						episode = match;
            		    if(Utils.getSafeMedia(episode[Constants.EPISODE_MEDIA]) != null){
                            episodeUrl = null;
		    			    System.println("Episode " + episode[Constants.EPISODE_ID] + " already downloaded!");
                        }
					}
		
					episodes.add(episode);	
		    		episodesUrl.add(episodeUrl);
				}
		   	}
        } else {
            errorCallback.invoke("Error " + responseCode);
            return;
        }

        podcastEpisodesIterator.next();
    }

    function getEpisodesDone(){
        // Clean media
    	for(var i=0; i<saved.size(); i++){
			var x = Utils.findArrayField(episodes, Constants.EPISODE_ID, saved[i][Constants.EPISODE_ID]);
    		if(x == null){  		
    			System.println("Episode " + saved[i][Constants.EPISODE_ID] + " no longer needed!");
    			    			
            	var mediaObj = Utils.getSafeMedia(saved[i][Constants.EPISODE_MEDIA]);
				if(mediaObj != null){
					Media.deleteCachedItem(mediaObj.getContentRef());
				}
    		}
    	}
        doneCallback.invoke();
    }
}