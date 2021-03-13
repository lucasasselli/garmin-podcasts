using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Cryptography;
using Toybox.StringUtil;
using Toybox.Application.Storage;

class EpisodeManager {

    var provider;

    var loadingShown;

    var podcasts;
    var podcastsMenu;

    var progressBar;

    var saved;
    var downloads = [];

    function initialize(){
        provider = new PodcastsProviderWrapper();
        progressBar = new WatchUi.ProgressBar(WatchUi.loadResource(Rez.Strings.loading), null);
        saved = StorageHelper.get(Constants.STORAGE_SAVED, []);
    }

    function showLoading(){
        loadingShown = true;
        WatchUi.pushView(progressBar, new RemoteProgressDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }

	function show(){
        if(provider.getPodcasts(method(:podcastsDone), method(:podcastsError))){
            // Remote request, show progress bar
            showLoading();
        }
	}

    function podcastsDone(podcasts){
        self.podcasts = podcasts;
		if(podcasts.size() > 0){
		    podcastsMenu = new CompactMenu(Rez.Strings.selectEpisodes);
            podcastsMenu.setBackCallback(method(:onPodcastBack));
			for(var i=0; i<podcasts.size(); i++){
                podcastsMenu.add(podcasts[i][Constants.PODCAST_TITLE], podcasts[i][Constants.PODCAST_AUTHOR], method(:getEpisodes)); 
			}
            podcastsMenu.show();
        }else{
			WatchUi.pushView(new AlertView(Rez.Strings.errorNoSubscriptions), null, WatchUi.SLIDE_LEFT); 
        }
    }

    function podcastsError(msg){
        if(loadingShown){
            WatchUi.switchToView(new AlertView(msg), null, WatchUi.SLIDE_LEFT); 
        }else{
            WatchUi.pushView(new AlertView(msg), null, WatchUi.SLIDE_LEFT); 
        }
    }

    function getEpisodes(){
        var podcast = podcasts[podcastsMenu.getSelected()];
        showLoading();
    	PodcastIndex.request(Constants.URL_PODCASTINDEX_EPISODES, {"id" => podcast[Constants.PODCAST_ID], "max" => "500"}, method(:onEpisodes));
    }

    function onEpisodes(responseCode, data) {
        var podcast = podcasts[podcastsMenu.getSelected()];

        if (responseCode != 200) { 
	        WatchUi.switchToView(new AlertView("Error " + responseCode), null, WatchUi.SLIDE_LEFT); 
        }

        var items = Utils.getSafeDictKey(data, "items");
        if(items != null && items.size() > 0){
            var episodesMenu = new WatchUi.CheckboxMenu({});
            for(var i=0; i<items.size(); i++){

                var downloadItem = PodcastIndex.itemToDownload(items[i], podcast);

                var found = false;
                for(var i=0; i<saved.size(); i++){
                    if(downloadItem[Constants.DOWNLOAD_DATA][Constants.EPISODE_ID] == saved[i][Constants.EPISODE_ID]){
                        found = true;
                        break;
                    }
                }
                for(var i=0; i<downloads.size(); i++){
                    if(downloadItem[Constants.DOWNLOAD_DATA][Constants.EPISODE_ID] == downloads[i][Constants.DOWNLOAD_DATA][Constants.EPISODE_ID]){
                        found = true;
                        break;
                    }
                }

                episodesMenu.addItem(new WatchUi.CheckboxMenuItem(downloadItem[Constants.DOWNLOAD_DATA][Constants.EPISODE_TITLE], "", downloadItem, found, {}));
            }
            WatchUi.switchToView(episodesMenu, new EpisodeSelectDelegate(self.weak()), WatchUi.SLIDE_LEFT); 
        }else{
	        WatchUi.pushView(new AlertView(Rez.Strings.msgNoEpisodes), null, WatchUi.SLIDE_LEFT);
        }

    }

    function onPodcastBack(){
        Storage.setValue(Constants.STORAGE_DOWNLOADS, downloads);
        WatchUi.pushView(new WatchUi.Confirmation(WatchUi.loadResource(Rez.Strings.confirmSync)), new ConfirmSyncDelegate(), WatchUi.SLIDE_LEFT);
        return true;
    }
}

class EpisodeSelectDelegate extends WatchUi.Menu2InputDelegate {

    private var main;

    function initialize(main) {
        self.main = main;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if(main.stillAlive()){
            var mainStrong = main.get();
            var episode = item.getId();
            if (item.isChecked()) {
                mainStrong.downloads.add(item.getId());
            } else {
                mainStrong.downloads.remove(item.getId());
            }
        }
    }
}

class ConfirmSyncDelegate extends WatchUi.ConfirmationDelegate {

    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {    	
        WatchUi.popView(WatchUi.SLIDE_LEFT);
		if(response == CONFIRM_YES){		
            Communications.startSync();
		}
	}
}