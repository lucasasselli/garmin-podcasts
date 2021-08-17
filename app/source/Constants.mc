module Constants {

    const URL_PODCASTINDEX_ROOT = "https://us-central1-garminpodcasts-307017.cloudfunctions.net/podcast-index-minify-1";
    const URL_FEEDPARSER_ROOT = "https://us-central1-garminpodcasts-307017.cloudfunctions.net/feed-parser-2";

    const URL_PODCASTINDEX_SEARCH   = URL_PODCASTINDEX_ROOT + "/api/1.0/search/byterm";

    const PODCASTINDEX_MAX_PODCASTS = 30;
    const FEEDPARSER_MAX_EPISODES = 300;

    const URL_GPODDER_ROOT = "https://gpodder.net/";

    const ART_PREFIX = "art_";

    const IMAGE_SIZE = 64;
    const CUSTOM_MENU_HEIGHT = 108;

    const STORAGE_VERSION_VALUE = 4;

    // Data structures
    enum {
        STORAGE_VERSION,
        STORAGE_SUBSCRIBED,
        STORAGE_EPISODES,
        STORAGE_PLAYLIST,
        STORAGE_ARTWORKS,
        STORAGE_MANUAL_SYNC
    }

    enum {
        PODCAST_URL,
        PODCAST_ARTWORK,
        PODCAST_TITLE,
        PODCAST_DATA_SIZE
    }

    enum {
        EPISODE_PODCAST,
        EPISODE_TITLE,
        EPISODE_DATE,
        EPISODE_DURATION,
        EPISODE_MEDIA,
        EPISODE_PROGRESS,
        EPISODE_DATA_SIZE
    }
}