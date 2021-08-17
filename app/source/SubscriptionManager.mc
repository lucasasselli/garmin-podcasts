using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Cryptography;
using Toybox.StringUtil;
using Toybox.Application.Storage;

using CompactLib.Ui;

class SubscriptionManager extends Ui.CompactMenu {

    var searchResults;

    function initialize(){
        CompactMenu.initialize(Rez.Strings.AppName);
    }

    function build(){
        add(Rez.Strings.menuSearch, null, method(:callbackSearch));
        add(Rez.Strings.menuSubscribed, method(:getSubscribedCount), method(:callbackSubscribed));
    }

    // Search new podcast
    function callbackSearch(){
        if (WatchUi has :TextPicker) {
            WatchUi.pushView(new WatchUi.TextPicker(""), new PickerSearchDelegate(method(:onSearchQuery)), WatchUi.SLIDE_LEFT);
        }else{
            var fallbackPickerSearch = new FallbackPicker("");
            WatchUi.pushView(fallbackPickerSearch, new FallbackPickerSearchDelegate(fallbackPickerSearch, method(:onSearchQuery)), WatchUi.SLIDE_LEFT);
        }
    }

    // Return number of subscribed podcast strings
    function getSubscribedCount(){
        var subscribed = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, []);
        return subscribed.size().toString() + " " + WatchUi.loadResource(Rez.Strings.podcasts);
    }

    // Manage subscribed podcasts
    function callbackSubscribed(){

        var podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        var podcastIds = podcasts.keys();

        if(podcasts.size() > 0){
            var menu = new WatchUi.Menu2({:title=> Rez.Strings.titleSubscriptionMenu });

            for(var i=0; i<podcastIds.size(); i++){

                var podcast = podcasts[podcastIds[i]];

                menu.addItem(
                    new WatchUi.MenuItem(
                        podcast[Constants.PODCAST_TITLE],
                        null,
                        podcastIds[i],
                    {})
                );
            }
            WatchUi.pushView(menu, new ConfirmMenuDelegate(Rez.Strings.confirmUnsubscribe, method(:onPodcastRemove)), WatchUi.SLIDE_LEFT);
        } else {
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoSubscriptions);
            alert.show();
        }
    }

    function onSearchQuery(query){
        var searchRequest = new CompactLib.Utils.CompactRequest(WatchUi.loadResource(Rez.JsonData.connectionErrors));
        searchRequest.setOptions(Remote.getPodcastIndexRequestOptions());
        searchRequest.requestPickerFixProgress(
            Constants.URL_PODCASTINDEX_SEARCH,
            {
                "q"   => StringHelper.substringReplace(query, " ", "+"),
                "max" => Constants.PODCASTINDEX_MAX_PODCASTS
            },
            method(:onSearchResults),
            null);
    }

    function onSearchResults(data, context) {

        var feeds = Utils.getSafeDictKey(data, "feeds");

        if(feeds == null || feeds.size() == 0){
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoResults);
            alert.switchTo();
            return;
        }

        var menu = new WatchUi.Menu2({:title=>Rez.Strings.titleResultsMenu});

        for (var i=0; i<feeds.size(); i++) {
            var podcast = Remote.feedToPodcast(feeds[i], feeds[i]["url"]);
            if(podcast != null){
                menu.addItem(
                    new WatchUi.MenuItem(
                        podcast[Constants.PODCAST_TITLE],
                        feeds[i]["author"],
                        podcast,
                    {}
                    ));
            }
        }

        WatchUi.switchToView(menu, new ConfirmMenuDelegate(Rez.Strings.confirmSubscribe, method(:onPodcastAdd)), WatchUi.SLIDE_LEFT);
    }

    function onPodcastAdd(context){
        var subscribed = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        subscribed.put(Utils.hash(context[Constants.PODCAST_URL]), context);
        Storage.setValue(Constants.STORAGE_SUBSCRIBED, subscribed);
    }

    function onPodcastRemove(context){
        var subscribed = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        subscribed.remove(context);
        Storage.setValue(Constants.STORAGE_SUBSCRIBED, subscribed);
    }
}

class PickerSearchDelegate extends WatchUi.TextPickerDelegate {

    hidden var callback;

    function initialize(callback) {
        self.callback = callback;
        TextPickerDelegate.initialize();
    }

    function onTextEntered(text, changed)
    {
        callback.invoke(text);
    }
}

class FallbackPickerSearchDelegate extends WatchUi.PickerDelegate {

    hidden var picker;
    hidden var callback;

    function initialize(picker, callback) {
        PickerDelegate.initialize();
        self.picker = picker;
        self.callback = callback;
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function onAccept(values) {
        if(!picker.isDone(values[0])) {
            picker.addCharacter(values[0]);
        } else {
            callback.invoke(picker.getText());
        }
    }
}