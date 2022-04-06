using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application.Storage;

using CompactLib.Ui;
using CompactLib.StringHelper;

class PodcastsProvider_GPodder extends PodcastsProviderBase {

    var feedsIterator;

    var username;
    var password;
    var deviceid;
    var serviceroot;

    var headers;

    var podcastRequestParams;

    function initialize(){

        username = Application.getApp().getProperty("settingUsername");
        password = Application.getApp().getProperty("settingPassword");
        deviceid = Application.getApp().getProperty("settingDeviceId");

        serviceroot = Application.getApp().getProperty("settingServiceUrl");
        if(!StringHelper.notNullOrEmpty(serviceroot)){
            serviceroot = Constants.URL_GPODDER_ROOT;
        }
        if(serviceroot.find("http") != 0){
            serviceroot = "https://" + serviceroot;
        }
        if(!serviceroot.substring(serviceroot.length() - 1, serviceroot.length()).equals("/")){
            serviceroot = serviceroot + "/";
        }

        headers = {
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
            "Authorization" => "Basic " + StringUtil.encodeBase64(username + ":" + password),
        };

        PodcastsProviderBase.initialize(true);
    }

    function valid(){
        // Valid when username, password and deviceId are set
        return (StringHelper.notNullOrEmpty(username) && StringHelper.notNullOrEmpty(password) && StringHelper.notNullOrEmpty(deviceid));
    }

    function download(){
        login(method(:getSubscriptions));
    }

    function add(podcast, doneCallback, errorCallback){
        PodcastsProviderBase.add(podcast, doneCallback, errorCallback);
        podcastRequestParams = { "add" => [ podcast[Constants.PODCAST_URL] ], "remove" => []};
        login(method(:manageSubscription));
    }

    function remove(podcast, doneCallback, errorCallback){
        PodcastsProviderBase.remove(podcast, doneCallback, errorCallback);
        podcastRequestParams = { "add" => [], "remove" => [ podcast[Constants.PODCAST_URL] ] };
        login(method(:manageSubscription));
    }

    function error(code){
        var msg = WatchUi.loadResource(Rez.JsonData.connectionErrors).get(code.toString());
        if(msg != null){
            PodcastsProviderBase.error(msg);
        }else{
            PodcastsProviderBase.error("Error " + code);
        }
    }

    function login(callback){
        Communications.makeWebRequest(
            serviceroot + "api/2/auth/" + username + "/login.json",
            null,
            {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => headers
            },
            callback);
    }

    // Get subscriptions
    function getSubscriptions(responseCode, data){
        if (Utils.validResponse(responseCode)) {
            Communications.makeWebRequest(
                serviceroot + "subscriptions/" + username + "/" + deviceid + ".json",
                null,
                {
                    :method => Communications.HTTP_REQUEST_METHOD_GET,
                    :headers => headers,
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
                },
                method(:onSubscriptions));
        } else {
            error(responseCode);
        }
    }

    // Get subscriptions - Subscriptions received
    function onSubscriptions(responseCode, data){
        if (Utils.validResponse(responseCode)) {
            var new_podcasts_urls = [];
            var removed_podcasts = podcasts.keys();

            for(var i=0; i<data.size(); i++){
                var url = data[i];
                if(!removed_podcasts.remove(Utils.hash(url))){
                    new_podcasts_urls.add(url);
                }
            }

            for(var i=0; i<removed_podcasts.size(); i++){
                podcasts.remove(removed_podcasts[i]);
            }

            feedsIterator = new CompactLib.Utils.Iterator(new_podcasts_urls, method(:getFeedInfo), method(:getFeedsDone));
            feedsIterator.next();
        } else {
            error(responseCode);
        }
    }

    function getFeedInfo(item){
        Log.debug("Getting feed info for " + item);
        var podcastInfoRequest = new CompactLib.Utils.CompactRequest(null);
        podcastInfoRequest.request(
            Constants.URL_FEEDPARSER_ROOT,
            {"feedUrl" => item, "max" => "0"},
            method(:onFeedInfo),
            item);
    }

    function onFeedInfo(responseCode, data, context){
        if (Utils.validResponse(responseCode)) {
            var progress_val = feedsIterator.index().toFloat()/feedsIterator.size().toFloat();
            progress((progress_val*100).toNumber());

            // FIXME: Might never be null!
            var podcast = Data.parsePodcast(data, context);
            if(podcast != null){
                podcasts.put(Utils.hash(context), podcast);
            }
        } else {
            error(responseCode);
        }

        feedsIterator.next();
    }

    function getFeedsDone(){
        Storage.setValue(Constants.STORAGE_SUBSCRIBED, podcasts);
        done(podcasts);
    }

    function manageSubscription(responseCode, data){
        if (Utils.validResponse(responseCode)) {
            Communications.makeWebRequest(
                serviceroot + "api/2/subscriptions/" + username + "/" + deviceid + ".json",
                podcastRequestParams,
                {
                    :method => Communications.HTTP_REQUEST_METHOD_POST,
                    :headers => {
                        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
                        "Authorization" => "Basic " + StringUtil.encodeBase64(username + ":" + password),
                    },
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
                },
                method(:onSubscriptionManage));
        } else {
            error(responseCode);
        }
    }

    function onSubscriptionManage(responseCode, data){
        getSubscriptions(responseCode, null);
    }
}