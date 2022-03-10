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

    function getSubscriptions(responseCode, data){
        if (responseCode == 200 || responseCode == -400) {
            Communications.makeWebRequest(
                serviceroot + "index.php/apps/gpoddersync/subscriptions/",
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
}