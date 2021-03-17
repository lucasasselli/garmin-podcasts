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
    var episodes;
    var menuEpisodes;

    function initialize(){
        provider = new PodcastsProviderWrapper();
        saved = StorageHelper.get(Constants.STORAGE_EPISODES, {});
        episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
    }

    function showLoading(){
        progressBar = new WatchUi.ProgressBar(WatchUi.loadResource(Rez.Strings.loading), null);
        WatchUi.pushView(progressBar, new RemoteProgressDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }

	function show(){
        if(provider.get(method(:podcastsDone), method(:showError))){
            showLoading();
        }
	}

    function podcastsDone(podcasts){
        self.podcasts = podcasts;
		if(podcasts != null && podcasts.size() > 0){
		    podcastsMenu = new CompactMenu(Rez.Strings.selectEpisodes);
            podcastsMenu.setBackCallback(method(:onPodcastBack));
			for(var i=0; i<podcasts.size(); i++){
                podcastsMenu.add(podcasts[i][Constants.PODCAST_TITLE], method(:getSelected), method(:getEpisodes)); 
			}

            if(progressBar == null){
                podcastsMenu.show();
            }else{
                podcastsMenu.switchTo();
            }
            progressBar = null;
        }else{
			showError(Rez.Strings.errorNoSubscriptions);
        }
    }

    function getSelected(){
        var podcastId = podcasts[podcastsMenu.getSelected()][Constants.PODCAST_ID];
        var count = 0;
        for(var i=0; i<episodes.size(); i++){
            if(episodes.values()[i][Constants.EPISODE_PODCAST] == podcastId){
                count++;
            }
        }

        return count + " selected";
    }

    function showError(msg){
        if(progressBar != null){
            WatchUi.switchToView(new AlertView(msg), null, WatchUi.SLIDE_LEFT); 
        }else{
            WatchUi.pushView(new AlertView(msg), null, WatchUi.SLIDE_LEFT); 
        }
        progressBar = null;
    }

    function getEpisodes(){
        var podcast = podcasts[podcastsMenu.getSelected()];
        showLoading();
    	PodcastIndex.request(
            Constants.URL_PODCASTINDEX_EPISODES, 
            {"id" => podcast[Constants.PODCAST_ID], "max" => Constants.PODCASTINDEX_MAX_EPISODES}, 
            method(:onEpisodes));
    }

    function onEpisodes(responseCode, data) {
        menuEpisodes = {};

        var podcast = podcasts[podcastsMenu.getSelected()];

        if (responseCode != 200) { 
            showError("Error" + responseCode);
        }

        var items = Utils.getSafeDictKey(data, "items");
        if(items != null && items.size() > 0){
            var episodesMenu = new WatchUi.CheckboxMenu({:title => podcast[Constants.PODCAST_TITLE]});
            for(var i=0; i<items.size(); i++){
                var id = items[i]["id"];
                var episode = PodcastIndex.itemToEpisode(items[i], podcast);
                menuEpisodes.put(id, episode);
                episodesMenu.addItem(new WatchUi.CheckboxMenuItem(episode[Constants.EPISODE_TITLE], "", id, episodes.hasKey(id), {}));
            }
                
            WatchUi.switchToView(episodesMenu, new EpisodeSelectDelegate(self.weak()), WatchUi.SLIDE_LEFT); 
        }else{
	        showError(Rez.Strings.msgNoEpisodes);
        }

    }

    function onPodcastBack(){
        Storage.setValue(Constants.STORAGE_EPISODES, episodes);
        var prompt = new CompactPrompt(Rez.Strings.confirmSync, method(:startSync), null);
        prompt.show();
        return true;
    }

    function startSync(){
        Communications.startSync();
    }
}

class EpisodeSelectDelegate extends WatchUi.Menu2InputDelegate {

    private var parentRef;

    function initialize(parentRef) {
        self.parentRef = parentRef;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if(parentRef.stillAlive()){
            var parent = parentRef.get();
            var id = item.getId();
            if (item.isChecked()) {
                if(parent.saved.hasKey(id)){
                    // If the episode is saved, use it to avoid loosing media
                    parent.episodes.put(id, parent.saved[id]);
                }else{
                    parent.episodes.put(id, parent.menuEpisodes[id]);
                }
            } else {
                parent.episodes.remove(item.getId());
            }
        }
    }
}