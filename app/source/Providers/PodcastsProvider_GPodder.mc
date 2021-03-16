using Toybox.Communications;
using Toybox.Application.Storage;

class PodcastProvider_GPodder {

    var feedsIterator;

    var podcasts = [];

    var username;
    var password;
    var deviceid;

    var doneCallback;
    var errorCallback;

    var headers;

    function initialize(){
        username = Application.getApp().getProperty("settingUsername");
        password = Application.getApp().getProperty("settingPassword");
		headers = {
			"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
			"Authorization" => "Basic " + StringUtil.encodeBase64(username + ":" + password),
		};
    }

    function valid(){
        return (StringHelper.notNullOrEmpty(username) && StringHelper.notNullOrEmpty(password));
    }

    function get(doneCallback, errorCallback){
        self.podcasts = podcasts;
        self.errorCallback = errorCallback;
        self.doneCallback = doneCallback;

        // Login to gPodder
	   	Communications.makeWebRequest(
	   		Constants.URL_GPODDER_ROOT + "api/2/auth/" + username + "/login.json", 
	   		null, 
	   		{
		    	:method => Communications.HTTP_REQUEST_METHOD_POST,
		    	:headers => headers,
		    	:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
	   		},
	   		method(:onLogin));
        
        return true;
    }

    function onLogin(responseCode, data){
        if (responseCode == 200 || responseCode == -400) { 
            Communications.makeWebRequest(
                Constants.URL_GPODDER_ROOT + "subscriptions/" + username + ".json", 
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
            var urls = [];
            for(var i=0; i<data.size(); i++){
                urls.add(data[i]["url"]);
            }
            feedsIterator = new Iterator(urls, method(:getFeeds), method(:getFeedsDone));
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
                var podcast = PodcastIndex.feedToPodcast(feed);
                podcasts.add(podcast);
	       	}
        } else if (responseCode == 400) {
            // Feed not found!
        } else {
            errorCallback.invoke("Feed error " + responseCode);
        }
           
        feedsIterator.next();
    }

    function getFeedsDone(){
        doneCallback.invoke(podcasts);
    }


    function manage(){
        WatchUi.pushView(new AlertView(Rez.Strings.msgCheckPhone), null, WatchUi.SLIDE_LEFT);
        Communications.openWebPage(Constants.URL_GPODDER_ROOT, {}, null);
    }
}