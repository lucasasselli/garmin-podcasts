using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Cryptography;
using Toybox.StringUtil;

class PodcastIndex {

    function getRequestOptions(){
        var now = Time.now().value();
        var auth = Utils.hash(Secrets.TOKEN + Secrets.SECRET + now);

        var headers = {
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
            "X-Auth-Date" => now.format("%d"),
            "X-Auth-Key" => Secrets.TOKEN,
            "Authorization" => auth,
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => headers,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };

        return options;
    }

    function itemToEpisode(item, podcastId){
        var episode = new [Constants.EPISODE_DATA_SIZE];
        episode[Constants.EPISODE_URL] = item["enclosureUrl"];
        episode[Constants.EPISODE_PODCAST] = podcastId;
        episode[Constants.EPISODE_DATE] = item["datePublished"];
        episode[Constants.EPISODE_TITLE] = item["title"];
        episode[Constants.EPISODE_DURATION] = item["duration"];
        return episode;
    }

    function feedToPodcast(data){
        var podcast = new [Constants.PODCAST_DATA_SIZE];

        var url = Utils.getSafeDictKey(data, "url");

        podcast[Constants.PODCAST_URL] = url;
        podcast[Constants.PODCAST_ARTWORK] = Utils.getSafeDictKey(data, "image");
        podcast[Constants.PODCAST_TITLE] = Utils.getSafeDictKey(data, "title");
        podcast[Constants.PODCAST_AUTHOR] = Utils.getSafeDictKey(data, "author");

        // TODO: Check if NULL

        return podcast;
    }
}