using Toybox.Application.Storage;
using Toybox.Media;
using Toybox.Cryptography;
using Toybox.StringUtil;
using Toybox.Communications;

class Utils {

    function findArrayField(array, field, value){
        if (array == null){
            return null;
        }

        for(var i=0; i<array.size(); i++){
            var x = array[i];
            if (field < x.size()){
                if(x[field] != null){
                    if (x[field].equals(value)){
                        return x;
                    }
                }
            }
        }

        return null;
    }

    function sortArrayField(array, field){
        var swapped;
        do {
            swapped = false;
            for(var i=0; i<array.size()-1; i++){
                if (array[i][field] < array[i+1][field]){
                    Utils.arraySwap(keys, i, i+1);
                    swapped = true;
                }
            }
        }while(swapped);
    }

    function arraySwap(array, i, j){
        var temp = array[i];
        array[i] = array[j];
        array = temp;
    }

    function getArrayField(array, field){

        if (array == null){
            return [];
        }

        var x = [];

        for(var i=0; i<array.size(); i++){

            x.add(array[i][field]);
        }

        return x;
    }

    function getSafeMedia(refId){
        var mediaObj = null;
        if(refId != null){
            try{
                var ref = new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);
                mediaObj = Media.getCachedContentObj(ref);
            }catch(ex){
                mediaObj = null;
            }
        }
        return mediaObj;
    }

    function purgeBadMedia(){

        var episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
        var podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});

        // Purge medias without episode
        var medias = Media.getContentRefIter({:contentType => Media.CONTENT_TYPE_AUDIO});
        if (medias != null) {
            var media = medias.next();
            while (media != null) {
                if(Utils.findArrayField(episodes.values(), Constants.EPISODE_MEDIA, media.getId()) == null){
                    System.println("Media " + media.getId() + " is not used by an episode. Deleting...");
                    var ref = new Media.ContentRef(media.getId(), Media.CONTENT_TYPE_AUDIO);
                    Media.deleteCachedItem(ref);
                }
                media = medias.next();
            }
        }

        // Purge episodes
        var episodeIds = episodes.keys();
        for (var i = 0; i < episodeIds.size(); i++) {

            var episode = episodes[episodeIds[i]];

            if(episode == null){
                episodes.remove(episodeIds[i]);
                System.println("Episode " + episodeIds[i] + " is null. Deleting...");
                continue;
            }

            // FIXME: Allow episodes without media to allow storing episode selection
            // var mediaObj = Utils.getSafeMedia(episode[Constants.EPISODE_MEDIA]);
            // if(mediaObj == null){
            //     episodes.remove(episodeIds[i]);
            //     System.println("Episode " + episodeIds[i] + " doesn't have a media. Deleting...");
            //     continue;
            // }

            var podcastId = episode[Constants.EPISODE_PODCAST];
            if(podcastId == null || !podcasts.hasKey(podcastId)){
                episodes.remove(episodeIds[i]);
                System.println("Episode " + episodeIds[i] + " doesn't have a podcast. Deleting...");
                continue;
            }
        }
        Storage.setValue(Constants.STORAGE_EPISODES, episodes);

        // Purge playlist episodes
        var playlist = StorageHelper.get(Constants.STORAGE_PLAYLIST, []);
        var purgedPlaylist = [];
        for(var i=0; i<playlist.size(); i++){
            var x = Utils.findArrayField(episodes.values(), Constants.EPISODE_MEDIA, playlist[i]);
            if(x != null){
                purgedPlaylist.add(playlist[i]);
            }else{
                System.println("Media " + playlist[i] + " doesn't exist anymore. Deleting from playlist...");
            }
        }
        Storage.setValue(Constants.STORAGE_PLAYLIST, purgedPlaylist);

        // Purge Artworks without podcast
        var artworks = StorageHelper.get(Constants.STORAGE_ARTWORKS, []);
        var purgedArtworks = [];

        for(var i=0; i<artworks.size(); i++){
            var x = Utils.findArrayField(episodes.values(), Constants.EPISODE_PODCAST, artworks[i]);
            if(x != null){
                purgedArtworks.add(artworks[i]);
            }else{
                Storage.deleteValue(Constants.ART_PREFIX + artworks[i]);
                System.println("Artwork " + artworks[i] + " no longer needed. Deleting...");
            }
        }
        Storage.setValue(Constants.STORAGE_ARTWORKS, purgedArtworks);
    }

    function hash(input){

        var hash = new Cryptography.Hash({
            :algorithm => Toybox.Cryptography.HASH_SHA1
        });

        var toArray = {
            :fromRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
            :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
            :encoding => StringUtil.CHAR_ENCODING_UTF8
        };

        var toString = {
            :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
            :toRepresentation => StringUtil.REPRESENTATION_STRING_HEX,
            :encoding => StringUtil.CHAR_ENCODING_UTF8
        };

        hash.update(StringUtil.convertEncodedString(input, toArray));

        return StringUtil.convertEncodedString(hash.digest(), toString);
    }

    function getPodcastIndexRequestOptions(){

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
}