using Toybox.Communications;
using Toybox.Application.Storage;

class GPodder {

    var feedsIterator;

    var podcasts;

    var username;
    var password;
    var deviceid;

    var doneCallback;
    var errorCallback;

    function initialize(){
        username = Application.getApp().getProperty("settingUsername");
        password = Application.getApp().getProperty("settingPassword");
        deviceid = Application.getApp().getProperty("settingDeviceid");
    }

    function valid(){
        return (StringHelper.notNullOrEmpty(username) && StringHelper.notNullOrEmpty(password) && StringHelper.notNullOrEmpty(deviceid));
    }

    function getPodcasts(podcasts, doneCallback, errorCallback){
        self.podcasts = podcasts;
        self.errorCallback = errorCallback;
        self.doneCallback = doneCallback;

        // Login to gPodder
		var headers = {
			"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
			"Authorization" => "Basic " + StringUtil.encodeBase64(username + ":" + password),
		};
	
	   	Communications.makeWebRequest(
	   		Constants.URL_GPODDER_ROOT + "api/2/auth/" + username + "/login.json", 
	   		null, 
	   		{
		    	:method => Communications.HTTP_REQUEST_METHOD_POST,
		    	:headers => headers,
		    	:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
	   		},
	   		method(:onLogin));
    }

    function onLogin(responseCode, data){
        if (responseCode == 200) { 
            var headers = {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            };
        
            Communications.makeWebRequest(
                Constants.URL_GPODDER_ROOT + "subscriptions/" + username + "/" + deviceid + ".json", 
                null, 
                {
                    :method => Communications.HTTP_REQUEST_METHOD_GET,
                    :headers => headers,
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
                },
                method(:onSubscriptions));
        } else {
            errorCallback.invoke("Login error " + responseCode);
        }
    }

    function onSubscriptions(responseCode, data){
        if (responseCode == 200) { 
            feedsIterator = new Iterator(data, method(:getFeeds), method(:getFeedsDone));
            feedsIterator.next();
        } else {
            errorCallback.invoke("List error " + responseCode);
        }
    }

    function getFeeds(item){
    	PodcastIndex.request(Constants.URL_PODCASTINDEX_FEED, {"url" => item }, method(:onFeed));
    }

    function onFeed(responseCode, data){
        if (responseCode == 200) {
	       	var feed = Utils.getSafeDictKey(data, "feed");
	       	if(feed != null){
                var podcast = new [Constants.PODCAST_DATA_SIZE];
                podcast[Constants.PODCAST_ID] 		= feed["id"];
                podcast[Constants.PODCAST_TITLE] 	= feed["title"];
                podcast[Constants.PODCAST_AUTHOR] 	= feed["author"];
                podcasts.add(podcast);
	       	}
            feedsIterator.next();
        } else {
            errorCallback.invoke("Feed error " + responseCode);
        }
    }

    function getFeedsDone(){
        // Remove artworks
    	var subscribed = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, []);
        for(var i=0; i<subscribed.size(); i++){
	        var found = Utils.findArrayField(podcasts, Constants.EPISODE_ID, subscribed[Constants.PODCAST_ID]);
            if(found == null){
                Storage.deleteValue(subscribed[i][Constants.PODCAST_ID]);
            }
        }
        Storage.setValue(Constants.STORAGE_SUBSCRIBED, podcasts);
        doneCallback.invoke();
    }
}