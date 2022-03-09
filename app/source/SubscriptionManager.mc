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
        add(Rez.Strings.menuPodcastsSearch, null, method(:callbackSearch));
        add(Rez.Strings.menuPodcastsSubscribed, method(:getSubscribedCount), method(:callbackSubscribed));

        var service = Application.getApp().getProperty("settingPodcastService");
        if(service > 0){
            add(Rez.Strings.menuPodcastsRefresh, null, method(:callbackRefreshSubscriptions));
        }
    }

    // Podcast search
    function callbackSearch(){
        var picker = new CompactLib.Ui.CompactPicker(method(:onSearchQuery));
        picker.show();
    }

    // Manage subscriptions
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
                        podcast,
                    {})
                );
            }
            // FIXME: Reuse confirmation view
            WatchUi.pushView(menu, new ConfirmMenuDelegate(Rez.Strings.confirmUnsubscribe, method(:onPodcastRemove)), WatchUi.SLIDE_LEFT);
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
        // FIXME: Add done callback
        $.podcastsProvider.get(null);
    }

    function onSearchQuery(query){
        var searchRequest = new CompactLib.Utils.CompactRequest(WatchUi.loadResource(Rez.JsonData.connectionErrors));
        searchRequest.setOptions(Utils.getPodcastIndexRequestOptions());
        searchRequest.requestPickerProgress(
            Constants.URL_PODCASTINDEX_SEARCH,
            {
                "q"   => StringHelper.substringReplace(query, " ", "+"),
                "max" => Constants.PODCASTINDEX_MAX_PODCASTS
            },
            method(:onSearchResults),
            null);
    }

    function onSearchResults(data, context) {

        var feeds = data.get("feeds");

        if(feeds == null || feeds.size() == 0){
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoResults);
            alert.switchTo();
            return;
        }

        var menu = new WatchUi.Menu2({:title=>Rez.Strings.titleResultsMenu});

        for (var i=0; i<feeds.size(); i++) {
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
        // FIXME: Reuse confirmation view
        WatchUi.switchToView(menu, new ConfirmMenuDelegate(Rez.Strings.confirmSubscribe, method(:onPodcastAdd)), WatchUi.SLIDE_LEFT);
    }

    function onPodcastAdd(context){
        $.podcastsProvider.add(context);
    }

    function onPodcastRemove(context){
        $.podcastsProvider.remove(context);
    }
}