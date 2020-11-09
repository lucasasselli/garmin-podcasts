module Constants {
	
    const URL_PODCASTINDEX_SEARCH   = "https://api.podcastindex.org/api/1.0/search/byterm";
    const URL_PODCASTINDEX_EPISODES = "https://api.podcastindex.org/api/1.0/episodes/byfeedid";
    const URL_PODCASTINDEX_FEED     = "https://api.podcastindex.org/api/1.0/podcasts/byfeedurl";

    const URL_GPODDER_ROOT = "https://gpodder.net/";

    const CONNECTION_ATTEMPTS = 3;
    
    enum {
        STORAGE_SUBSCRIBED,
        STORAGE_SAVED,
        STORAGE_PLAYLIST
    }
    
    const PODCAST_DATA_SIZE = 3;   
    enum {
    	PODCAST_ID,
        PODCAST_TITLE,
        PODCAST_AUTHOR
    }
    
    const EPISODE_DATA_SIZE = 4;   
    enum {
    	EPISODE_ID,
    	EPISODE_PODCAST,
        EPISODE_MEDIA,
        EPISODE_DATE
    }
}