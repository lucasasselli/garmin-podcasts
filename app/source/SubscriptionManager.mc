using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Cryptography;
using Toybox.StringUtil;
using Toybox.Application.Storage;
using Toybox.Time;
using Toybox.Time.Gregorian;

using CompactLib.Ui;

class SubscriptionManager extends Ui.CompactMenu {

    function initialize(){
        CompactMenu.initialize(Rez.Strings.menuPodcasts);
    }

    function build(){
        add(Rez.Strings.menuPodcastsSubscribe, null, method(:callbackSubscribe));
        add(Rez.Strings.menuPodcastsUnsubscribe, method(:getSubscribedCount), method(:callbackUnsubscribe));

        var service = Application.getApp().getProperty("settingPodcastService");
        if(service > 0){
            add(Rez.Strings.menuPodcastsRefresh, null, method(:callbackRefreshSubscriptions));
        }
    }

    // Subscribe
    function callbackSubscribe(){
        var picker = new CompactLib.Ui.CompactPicker(method(:onSubscribeQuery));
        picker.show();
    }

    // Unsubscribe
    function callbackUnsubscribe(){

        var podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        var podcastIds = podcasts.keys();

        if(podcasts.size() > 0){
            var menu = new WatchUi.Menu2({:title=> Rez.Strings.menuPodcastsUnsubscribe });

            for(var i=0; i<podcastIds.size(); i++){

                var podcast = podcasts[podcastIds[i]];

                menu.addItem(
                    new WatchUi.MenuItem(
                        podcast[Constants.PODCAST_TITLE],
                        null,
                        podcast,
                    {})
                );
            }
            WatchUi.pushView(menu, new SubscriptionMenuDelegate(method(:onSubscriptionRemove)), WatchUi.SLIDE_LEFT);
        } else {
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoSubscriptions);
            alert.show();
        }
    }

    // Return subscribed count
    function getSubscribedCount(){
        var subscribed = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});
        return subscribed.size().toString() + " " + WatchUi.loadResource(Rez.Strings.podcasts);
    }

    // Refresh subscriptions
    function callbackRefreshSubscriptions(){
        $.podcastsProvider.get(method(:onProgressDone));
    }

    function onSubscribeQuery(query){
        var searchRequest = new CompactLib.Utils.CompactRequest(WatchUi.loadResource(Rez.JsonData.connectionErrors));
        searchRequest.setOptions(Utils.getPodcastIndexRequestOptions());
        searchRequest.requestPickerProgress(
            Constants.URL_PODCASTINDEX_SEARCH,
            {
                "q"   => StringHelper.substringReplace(query, " ", "+"),
                "max" => Constants.PODCASTINDEX_MAX_PODCASTS
            },
            method(:onSubscribeResults),
            null);
    }

    function onSubscribeResults(data, context) {

        var feeds = data.get("feeds");

        if(feeds == null || feeds.size() == 0){
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoResults);
            alert.switchTo();
            return;
        }

        var menu = new WatchUi.Menu2({:title=>Rez.Strings.titleResultsMenu});

        for (var i=0; i<feeds.size(); i++) {
            // FIXME: Might never be null!
            var podcast = Data.parsePodcast(feeds[i], feeds[i]["url"]);
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
        WatchUi.switchToView(menu, new SubscriptionMenuDelegate(method(:onSubscriptionAdd)), WatchUi.SLIDE_LEFT);
    }

    function onSubscriptionAdd(context){
        $.podcastsProvider.add(context, method(:onProgressDone));
    }

    function onSubscriptionRemove(context){
        $.podcastsProvider.remove(context, method(:onProgressDone));
    }

    function onProgressDone(podcasts, hasProgress){
        if(hasProgress){
            WatchUi.popView(WatchUi.SLIDE_LEFT);
        }
    }
}

class SubscriptionMenuDelegate extends WatchUi.Menu2InputDelegate {

    hidden var msg;
    hidden var callback;

    function initialize(callback) {
        self.callback = callback;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        callback.invoke(item.getId());
    }
}