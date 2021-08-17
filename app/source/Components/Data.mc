using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Cryptography;
using Toybox.StringUtil;

class Data {

    function parseEpisode(data, podcastId){

        var episode = new [Constants.EPISODE_DATA_SIZE];

        episode[Constants.EPISODE_PODCAST] = podcastId;
        episode[Constants.EPISODE_DATE] = data["date"];
        episode[Constants.EPISODE_TITLE] = data["title"];
        episode[Constants.EPISODE_DURATION] = data["length"];

        // Media and duration CAN be null!
        for(var i=0; i<Constants.EPISODE_DATA_SIZE-2; i++){
            if(episode[i] == null){
                System.println(i);
                return null;
            }
        }

        return episode;
    }

    function parsePodcast(data, url){

        var podcast = new [Constants.PODCAST_DATA_SIZE];

        podcast[Constants.PODCAST_URL] = url;
        podcast[Constants.PODCAST_ARTWORK] = data.get("image");
        podcast[Constants.PODCAST_TITLE] = data.get("title");

        for(var i=0; i<Constants.PODCAST_DATA_SIZE; i++){
            if(podcast[i] == null){
                return null;
            }
        }

        return podcast;
    }

    function genPodcastId(podcast){
        return Utils.hash(podcast[Constants.PODCAST_URL]);
    }

    function genEpisodeId(episode){
        return episode[Constants.EPISODE_PODCAST] + "_" + episode[Constants.EPISODE_DATE];
    }
}