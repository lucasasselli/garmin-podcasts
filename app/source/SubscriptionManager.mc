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
    private var menu;
    private var toDelete = [];

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
            menu = new WatchUi.Menu2({:title=> Rez.Strings.menuPodcastsUnsubscribe });

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
            toDelete = [];
            WatchUi.pushView(menu, new SubscriptionMenuDelegate(method(:onSelectUnsubscribe), method(:deletePrompt)), WatchUi.SLIDE_LEFT);
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

        menu = new WatchUi.CheckboxMenu({:title=>Rez.Strings.titleResultsMenu});
        var podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});

        for (var i=0; i<feeds.size(); i++) {
            // FIXME: Might never be null!
            var podcast = Data.parsePodcast(feeds[i], feeds[i]["url"]);
            if(podcast != null){
                menu.addItem(
                    new WatchUi.CheckboxMenuItem(
                        podcast[Constants.PODCAST_TITLE],
                        feeds[i]["author"],
                        podcast,
                        podcasts.hasKey(Utils.hash(podcast[Constants.PODCAST_URL])),
                    {}
                    ));
            }
        }
        WatchUi.switchToView(menu, new SubscriptionMenuDelegate(method(:onSelectSubscribe), null), WatchUi.SLIDE_LEFT);
    }

    function onSelectSubscribe(context){
        if (menu.getItem(menu.findItemById(context)).isChecked()){
            $.podcastsProvider.add(context, null);
        }else{
            $.podcastsProvider.remove(context, null);
        }
    }

    function onSelectUnsubscribe(context){
        menu.deleteItem(menu.findItemById(context));
        toDelete.add(context);
        //if no more menu items, then popView
        if (menu.getItem(0)==null){
            deletePrompt();
        }
    }

    function deletePrompt(){
        if(toDelete.size() > 0){
            // ... something to delete, ask user to confirm
            var prompt = new Ui.CompactPrompt(Rez.Strings.confirmDelete, method(:callbackDelete), method(:exitView));
            prompt.show();
        }else{
            // Just exit
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
    }

    function exitView(){
        // Just exit
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function callbackDelete(){
        // Remove deleted subscription
        for(var i=0; i<toDelete.size(); i++){
            $.podcastsProvider.remove(toDelete[i], null);
        }
        exitView();
    }

    function onProgressDone(podcasts, hasProgress){
        if(hasProgress){
            WatchUi.popView(WatchUi.SLIDE_LEFT);
        }
    }
}

class SubscriptionMenuDelegate extends WatchUi.Menu2InputDelegate {

    hidden var msg;
    hidden var callbackOnSelect;
    hidden var callbackOnBack;

    function initialize(callbackOnSelect, callbackOnBack) {
        self.callbackOnSelect = callbackOnSelect;
        self.callbackOnBack = callbackOnBack;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        callbackOnSelect.invoke(item.getId());
    }

    function onBack() {
        if (callbackOnBack != null){
            callbackOnBack.invoke();
        }else{
            Menu2InputDelegate.onBack();
        }
    }
}