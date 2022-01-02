using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application.Storage;

using CompactLib.Ui;
using CompactLib.StringHelper;

class PodcastProvider_GPodder {

    var feedsIterator;

    var podcasts = {};

    var username;
    var password;
    var deviceid;
    var serviceroot;

    var doneCallback;
    var errorCallback;
    var progressCallback;

    var headers;

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

    }

    function valid(displayError){
        var validLogin = (StringHelper.notNullOrEmpty(username) && StringHelper.notNullOrEmpty(password));
        if(!validLogin && displayError){
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoCredentials);
            alert.show();
        }
        return validLogin;
    }

    function get(doneCallback, errorCallback){
        self.errorCallback = errorCallback;
        self.doneCallback = doneCallback;

        // Login to gPodder
        Communications.makeWebRequest(
            serviceroot + "api/2/auth/" + username + "/login.json",
            null,
            {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => headers,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
            },
            method(:onLogin));

        return true;
    }

    function setProgressCallback(callback){
        progressCallback = callback;
    }

    function onLogin(responseCode, data){
        if (responseCode == 200 || responseCode == -400) {
            var url;
            if(StringHelper.notNullOrEmpty(deviceid)){
                // Devige ID set
                url = serviceroot + "subscriptions/" + username + "/" + deviceid + ".json";
            }else{
                // Device ID not set
                url = serviceroot + "subscriptions/" + username + ".json";
            }

            Communications.makeWebRequest(
                url,
                null,
                {
                    :method => Communications.HTTP_REQUEST_METHOD_GET,
                    :headers => headers,
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
                },
                method(:onSubscriptions));
        } else if(responseCode == Communications.BLE_CONNECTION_UNAVAILABLE){
            errorCallback.invoke(WatchUi.loadResource(Rez.Strings.errorNoInternet));
        } else {
            // FIXME: Use JSON!
            errorCallback.invoke("Login error " + responseCode);
        }
    }

    function onSubscriptions(responseCode, data){
        if (responseCode == 200) {
            var urls = [];
            if(StringHelper.notNullOrEmpty(deviceid)){
                // Device ID set
                for(var i=0; i<data.size(); i++){
                    urls.add(data[i]);
                }
            }else{
                // Device ID not set
                for(var i=0; i<data.size(); i++){
                    urls.add(data[i]["url"]);
                }
            }
            feedsIterator = new CompactLib.Utils.Iterator(urls, method(:getFeedInfo), method(:getFeedsDone));
            feedsIterator.next();
        } else if (responseCode == Communications.NETWORK_RESPONSE_TOO_LARGE){
            // FIXME: Use JSON!
            errorCallback.invoke(WatchUi.loadResource(Rez.Strings.errorTooManySubs));
        } else {
            errorCallback.invoke("List error " + responseCode);
        }
    }

    function getFeedInfo(item){
        System.println("Getting feed info for " + item);
        var podcastInfoRequest = new CompactLib.Utils.CompactRequest(null);
        podcastInfoRequest.request(
            Constants.URL_FEEDPARSER_ROOT,
            {"feedUrl" => item, "max" => Constants.FEEDPARSER_MAX_EPISODES},
            method(:onFeedInfo),
            item);
    }

    function onFeedInfo(responseCode, data, context){
        if (responseCode == 200) {
            if(progressCallback != null){
                var progress = feedsIterator.index().toFloat()/feedsIterator.size().toFloat();
                progressCallback.invoke((progress*100).toNumber());
            }

            var podcast = Data.parsePodcast(data, context);
            if(podcast != null){
                podcasts.put(Utils.hash(context), podcast);
            }
        } else {
            System.println("Error " + responseCode + " while processing podcast feed " + feedsIterator.item());
        }

        feedsIterator.next();
    }

    function getFeedsDone(){
        Storage.setValue(Constants.STORAGE_SUBSCRIBED, podcasts);
        doneCallback.invoke(podcasts);
    }

    function manage(){
        var prompt = new Ui.CompactPrompt(Rez.Strings.msgSendNotification, method(:showNotification), null);
        prompt.show();
    }

    function showNotification(){
        Communications.openWebPage(serviceroot, {}, null);
    }
}