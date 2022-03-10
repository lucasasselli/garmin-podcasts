using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application.Storage;

using CompactLib.Ui;
using CompactLib.StringHelper;

class PodcastsProvider_Nextcloud extends PodcastsProvider_GPodder {

    function initialize(){
        PodcastsProvider_GPodder.initialize();
    }

    function login(callback){
        callback.invoke(200, null);
    }

    function valid(){
        // Valid when username, password and deviceId are set
        return (StringHelper.notNullOrEmpty(username) && StringHelper.notNullOrEmpty(password));
    }

    // Get subscriptions
    function getSubscriptions(responseCode, data){
        if (responseCode == 200) {
            Communications.makeWebRequest(
                serviceroot + "index.php/apps/gpoddersync/subscriptions?since=0",
                null,
                {
                    :method => Communications.HTTP_REQUEST_METHOD_GET,
                    :headers => {
                        "Authorization" => "Basic " + StringUtil.encodeBase64(username + ":" + password)
                    },
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
                },
                method(:onSubscriptions));
        } else {
            error(responseCode);
        }
    }

    // Get subscriptions - Subscriptions received
    function onSubscriptions(responseCode, data){
        PodcastsProvider_GPodder.onSubscriptions(responseCode, data["add"]);
    }

    function manageSubscription(responseCode, data){
        if (responseCode == 200) {
            Communications.makeWebRequest(
                serviceroot + "/index.php/apps/gpoddersync/subscription_change/create",
                podcastRequestParams,
                {
                    :method => Communications.HTTP_REQUEST_METHOD_POST,
                    :headers => {
                        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
                        "Authorization" => "Basic " + StringUtil.encodeBase64(username + ":" + password)
                    },
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
                },
                method(:onSubscriptionManage));
        } else {
            error(responseCode);
        }
    }
}