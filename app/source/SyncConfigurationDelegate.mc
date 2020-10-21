using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Cryptography;
using Toybox.StringUtil;
using Toybox.Application.Storage;

class SyncConfigurationDelegate extends WatchUi.Menu2InputDelegate {

	function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSearchQuery(query){
		Remote.request(
			Constants.URL_SEARCH, 
			{
				"q"   => Utils.stringReplace(query, " ", "+"),
				"max" => "5" // Safe number to avoid using all the memory
			}, 
			method(:onSearchResults));
    }

    function onSelect(item) {
    
        if (item.getId() == :search) {
            WatchUi.pushView(new TextPicker(""), new PickerSearchDelegate(method(:onSearchQuery)), WatchUi.SLIDE_LEFT);
        } else if (item.getId() == :subscribed) {  
                  	
        	var subscribed = Utils.getSafeStorageArray(Constants.STORAGE_SUBSCRIBED); 
        	      	
            if(subscribed.size() > 0){
            	var menu = new WatchUi.Menu2({:title=> Rez.Strings.titleSubscriptionMenu });
            	
            	for(var i=0; i<subscribed.size(); i++){
            		var podcast = subscribed[i];
       	            menu.addItem(
						new MenuItem(
							podcast[Constants.PODCAST_TITLE],
							podcast[Constants.PODCAST_AUTHOR],
							podcast,
						{})
					);     	
            	}
            	WatchUi.pushView(menu, new ConfirmMenuDelegate(Rez.Strings.confirmUnsubscribe, method(:onPodcastRemove)), WatchUi.SLIDE_LEFT);
            } else {
            	WatchUi.pushView(new ErrorView(Rez.Strings.errorNoSubscriptions), null, WatchUi.SLIDE_LEFT); 
            }
		}
    }

    function onSearchResults(responseCode, data) {
        if (responseCode == 200) {
            
	       	var feeds = Utils.getSafeDictKey(data, "feeds");
	       	if(feeds == null || feeds.size() == 0){
	       		WatchUi.pushView(new ErrorView(Rez.Strings.errorNoResults), null, WatchUi.SLIDE_IMMEDIATE);
	       		return;
	       	}
	       	
            var menu = new WatchUi.Menu2({:title=>Rez.Strings.titleResultsMenu});
	        for (var i=0; i<feeds.size(); i++) {
	        
	            var feed = feeds[i];       
	            var podcast = new [Constants.PODCAST_DATA_SIZE];
	            
	            podcast[Constants.PODCAST_ID] 		= feed["id"];
	            podcast[Constants.PODCAST_TITLE] 	= feed["title"];
	            podcast[Constants.PODCAST_AUTHOR] 	= feed["author"];
	            
	            menu.addItem(
					new WatchUi.MenuItem(
						feed["title"],
						feed["author"],
						podcast,
					{}
					));
	        }
	        
	        WatchUi.switchToView(menu, new ConfirmMenuDelegate(Rez.Strings.confirmSubscribe, method(:onPodcastAdd)), WatchUi.SLIDE_LEFT);
        } else {
            WatchUi.switchToView(new ErrorView(responseCode), null, WatchUi.SLIDE_IMMEDIATE);
        }
    }
    
    function onPodcastAdd(context){
 			var subscribed = Utils.getSafeStorageArray(Constants.STORAGE_SUBSCRIBED);
			var x = Utils.findArrayField(subscribed, Constants.PODCAST_ID, context[Constants.PODCAST_ID]);
			if(x == null){
				subscribed.add(context);
			}
			Storage.setValue(Constants.STORAGE_SUBSCRIBED, subscribed);
    }

	function onBack(){
    	WatchUi.popView(WatchUi.SLIDE_RIGHT);    	
		return true;
	}

    function onPodcastRemove(context){
		var subscribed = Utils.getSafeStorageArray(Constants.STORAGE_SUBSCRIBED);	
		var x = Utils.findArrayField(subscribed, Constants.PODCAST_ID, context[Constants.PODCAST_ID]);
		if(x != null){
			subscribed.remove(x);
			Storage.setValue(Constants.STORAGE_SUBSCRIBED, subscribed);
			Storage.deleteValue(x[Constants.PODCAST_ID]); // Delete artwork
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
		var progressBar = new WatchUi.ProgressBar(Rez.Strings.searching, null);
    	WatchUi.switchToView(progressBar, new SearchProgressDelegate(), WatchUi.SLIDE_IMMEDIATE);
    	WatchUi.pushView(progressBar, new SearchProgressDelegate(), WatchUi.SLIDE_IMMEDIATE); // Ugly fix
		callback.invoke(text);
		return true;
	}
}