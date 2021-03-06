using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Cryptography;
using Toybox.StringUtil;
using Toybox.Application.Storage;

class SubscriptionManager extends CompactMenu {

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
        var subscribed = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, []);

        if(subscribed.size() > 0){
            var menu = new WatchUi.Menu2({:title=> Rez.Strings.titleSubscriptionMenu });

            for(var i=0; i<subscribed.size(); i++){
                var podcast = subscribed[i];
                menu.addItem(
                    new WatchUi.MenuItem(
                        podcast[Constants.PODCAST_TITLE],
                        podcast[Constants.PODCAST_AUTHOR],
                        podcast,
                    {})
                );
            }
            WatchUi.pushView(menu, new ConfirmMenuDelegate(Rez.Strings.confirmUnsubscribe, method(:onPodcastRemove)), WatchUi.SLIDE_LEFT);
        } else {
            WatchUi.pushView(new AlertView(Rez.Strings.errorNoSubscriptions), null, WatchUi.SLIDE_LEFT);
        }
    }

    function onSearchQuery(query){
        PodcastIndex.request(
            Constants.URL_PODCASTINDEX_SEARCH,
            {
                "q"   => StringHelper.substringReplace(query, " ", "+"),
                "max" => Constants.PODCASTINDEX_MAX_PODCASTS
            },
            method(:onSearchResults));
    }

    function onSearchResults(responseCode, data) {
        if (responseCode == 200) {

               var feeds = Utils.getSafeDictKey(data, "feeds");
               if(feeds == null || feeds.size() == 0){
                   WatchUi.switchToView(new AlertView(Rez.Strings.errorNoResults), null, WatchUi.SLIDE_LEFT);
                   return;
               }

            var menu = new WatchUi.Menu2({:title=>Rez.Strings.titleResultsMenu});
            for (var i=0; i<feeds.size(); i++) {

                var feed = feeds[i];
                var podcast = new [Constants.PODCAST_DATA_SIZE];

                podcast[Constants.PODCAST_ID]         = feed["id"];
                podcast[Constants.PODCAST_TITLE]     = feed["title"];
                podcast[Constants.PODCAST_AUTHOR]     = feed["author"];

                menu.addItem(
                    new WatchUi.MenuItem(
                        feed["title"],
                        feed["author"],
                        podcast,
                    {}
                    ));
            }
            WatchUi.switchToView(menu, new ConfirmMenuDelegate(Rez.Strings.confirmSubscribe, method(:onPodcastAdd)), WatchUi.SLIDE_LEFT);
        }else if(responseCode == Communications.BLE_CONNECTION_UNAVAILABLE){
            // Not connected!!!
            WatchUi.switchToView(new AlertView(Rez.Strings.errorNoInternet), null, WatchUi.SLIDE_LEFT);
        }else if(responseCode == null || responseCode == Communications.REQUEST_CANCELLED){
            // Request cancelled... Do nothing!
        }else{
            WatchUi.switchToView(new AlertView("Error " + responseCode), null, WatchUi.SLIDE_LEFT);
        }
    }

    function onPodcastAdd(context){
        var subscribed = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, []);
        var x = Utils.findArrayField(subscribed, Constants.PODCAST_ID, context[Constants.PODCAST_ID]);
        if(x == null){
            subscribed.add(context);
        }
        Storage.setValue(Constants.STORAGE_SUBSCRIBED, subscribed);
    }

    function onPodcastRemove(context){
        var subscribed = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, []);
        var x = Utils.findArrayField(subscribed, Constants.PODCAST_ID, context[Constants.PODCAST_ID]);
        if(x != null){
            subscribed.remove(x);
            Storage.setValue(Constants.STORAGE_SUBSCRIBED, subscribed);
        }
    }
}

class SearchProgressDelegate extends WatchUi.BehaviorDelegate
{
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        Communications.cancelAllRequests();
        return false;
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
        var progressBar = new WatchUi.ProgressBar(WatchUi.loadResource(Rez.Strings.searching), null);
        WatchUi.switchToView(progressBar, new SearchProgressDelegate(), WatchUi.SLIDE_IMMEDIATE);
        callback.invoke(text);
        WatchUi.pushView(progressBar, new SearchProgressDelegate(), WatchUi.SLIDE_LEFT); // Ugly fix
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
            var progressBar = new WatchUi.ProgressBar(WatchUi.loadResource(Rez.Strings.searching), null);
            WatchUi.pushView(progressBar, new SearchProgressDelegate(), WatchUi.SLIDE_LEFT);
            callback.invoke(picker.getText());
        }
    }
}