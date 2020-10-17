using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Cryptography;
using Toybox.StringUtil;
using Toybox.Application.Storage;

class SyncConfigurationDelegate extends WatchUi.Menu2InputDelegate {
    
    function onSearchQuery(query){
		   								
		Remote.request(
			Constants.URL_SEARCH, 
			{
				"q"   => Utils.stringReplace(query, " ", "+"),
				"max" => "5" // Safe number to avoid using all the memory
			}, 
			method(:onSearchResults));

		WatchUi.pushView(new ProgressBar("Searching...", null), new SearchProgressDelegate(), WatchUi.SLIDE_LEFT);
    }
    
    function onSearchResults(responseCode, data) {
    
    	WatchUi.popView(WatchUi.SLIDE_RIGHT);    	
    	
        if (responseCode == 200) {
            
            var menu = new WatchUi.Menu2({:title=>Rez.Strings.titleResultsMenu});
            	
	       	var feeds = Utils.getSafeDictKey(data, "feeds");
	       	
	       	if(feeds == null || feeds.size() == 0){
	       		WatchUi.pushView(new ErrorView(responseCode), null, WatchUi.SLIDE_IMMEDIATE);
	       		return;
	       	}
	       	
	        for (var i=0; i<feeds.size(); i++) {
	        
	            var feed = feeds[i];       
	            var podcast = new [Constants.PODCAST_DATA_SIZE];
	            
	            podcast[Constants.PODCAST_ID] 		= feed["id"];
	            podcast[Constants.PODCAST_TITLE] 	= feed["title"];
	            podcast[Constants.PODCAST_AUTHOR] 	= feed["author"];
	            
	            menu.addItem(
					new MenuItem(
						feed["title"],
						feed["author"],
						podcast,
					{}
					));
	        }
	        
	        WatchUi.pushView(menu, new ConfirmMenuDelegate(Rez.Strings.confirmSubscribe, method(:onPodcastAdd)), WatchUi.SLIDE_LEFT);
	        
        } else {
            WatchUi.pushView(new ErrorView(responseCode), null, WatchUi.SLIDE_IMMEDIATE);
        }
        
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
		} else {
			WatchUi.pushView(new Rez.Menus.SettingsMain(), new SettingsMainDelegate(), WatchUi.SLIDE_LEFT);
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
    
    function onPodcastRemove(context){
		var subscribed = Utils.getSafeStorageArray(Constants.STORAGE_SUBSCRIBED);	
			
		var x = Utils.findArrayField(subscribed, Constants.PODCAST_ID, context[Constants.PODCAST_ID]);
		if(x != null){
			subscribed.remove(x);
				
			// Delete artwork
			Storage.deleteValue(x[Constants.PODCAST_ID]);

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
		WatchUi.popView(WatchUi.SLIDE_RIGHT);
		return true;
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