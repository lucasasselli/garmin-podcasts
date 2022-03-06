using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application.Storage;

using CompactLib.Ui;
using CompactLib.StringHelper;

class PodcastProvider_GPodder extends PodcastsProviderBase {

    var feedsIterator;

    var username;
    var password;
    var deviceid;
    var serviceroot;

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

        PodcastsProviderBase.initialize();
    }

    function valid(displayError){
        var validLogin = (StringHelper.notNullOrEmpty(username) && StringHelper.notNullOrEmpty(password) && StringHelper.notNullOrEmpty(deviceid));
        if(!validLogin && displayError){
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoCredentials);
            alert.show();
        }
        return validLogin;
    }

    function download(){

        podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});

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

    function onLogin(responseCode, data){
        // FIXME: Make device id mandatory!!!
        if (responseCode == 200 || responseCode == -400) {
            Communications.makeWebRequest(
                serviceroot + "subscriptions/" + username + "/" + deviceid + ".json",
                null,
                {
                    :method => Communications.HTTP_REQUEST_METHOD_GET,
                    :headers => headers,
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
                },
                method(:onSubscriptions));
        } else if(responseCode == Communications.BLE_CONNECTION_UNAVAILABLE){
            error(WatchUi.loadResource(Rez.Strings.errorNoInternet));
        } else {
            // FIXME: Use JSON!
            error("Login error " + responseCode);
        }
    }

    function onSubscriptions(responseCode, data){
        if (responseCode == 200) {
            var urls = [];
            // Device ID set
            for(var i=0; i<data.size(); i++){
                urls.add(data[i]);
            }
            feedsIterator = new CompactLib.Utils.Iterator(urls, method(:getFeedInfo), method(:getFeedsDone));
            feedsIterator.next();
        } else if (responseCode == Communications.NETWORK_RESPONSE_TOO_LARGE){
            error(WatchUi.loadResource(Rez.Strings.errorTooManySubs));
        } else {
            error("List error " + responseCode);
        }
    }

    function getFeedInfo(item){
        System.println("Getting feed info for " + item);
        var podcastInfoRequest = new CompactLib.Utils.CompactRequest(null);
        podcastInfoRequest.request(
            Constants.URL_FEEDPARSER_ROOT,
            {"feedUrl" => item, "max" => "0"},
            method(:onFeedInfo),
            item);
    }

    function onFeedInfo(responseCode, data, context){
        if (responseCode == 200) {
            var progress_val = feedsIterator.index().toFloat()/feedsIterator.size().toFloat();
            progress((progress_val*100).toNumber());

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
        done(podcasts);
    }

    function manage(){
        var prompt = new Ui.CompactPrompt(Rez.Strings.msgSendNotification, method(:showNotification), null);
        prompt.show();
    }

    function showNotification(){
        Communications.openWebPage(serviceroot, {}, null);
    }
}