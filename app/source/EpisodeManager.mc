using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Cryptography;
using Toybox.StringUtil;
using Toybox.Application.Storage;

using CompactLib.Ui;

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
        WatchUi.pushView(progressBar, new CompactLib.Utils.RemoteProgressDelegate(), WatchUi.SLIDE_LEFT);
    }

    function show(){
        if(provider.valid(true)){
            showLoading();
            provider.get(method(:podcastsDone), method(:showError));
        }
    }

    function podcastsDone(podcasts){
        self.podcasts = podcasts;
        if(podcasts != null && podcasts.size() > 0){
            podcastsMenu = new Ui.CompactMenu(Rez.Strings.selectEpisodes);
            podcastsMenu.setBackCallback(method(:onPodcastBack));

            var podcastIds = podcasts.keys();

            for(var i=0; i<podcastIds.size(); i++){
                podcastsMenu.add(podcasts[podcastIds[i]][Constants.PODCAST_TITLE], method(:getSelected), method(:getEpisodes));
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
        var podcastId = podcasts.keys()[podcastsMenu.getSelected()];
        var selected = 0;
        var downloaded = 0;
        for(var i=0; i<episodes.size(); i++){
            var episode = episodes.values()[i];
            if(episode[Constants.EPISODE_PODCAST].equals(podcastId)){
                if(episode[Constants.EPISODE_MEDIA] != null){
                    downloaded++;
                }
                selected++;
            }
        }

        if(downloaded > 0){
            if(selected > 0){
                return selected + " S " + downloaded  + " D";
            }else{
                return downloaded + " downloaded";
            }
        }else{
            if(selected > 0){
                return selected + " selected";
            }else{
                return null;
            }
        }
    }

    function showError(msg){
        var alert = new Ui.CompactAlert(msg);
        if(progressBar != null){
            alert.switchTo();
        }else{
            alert.show();
        }
        progressBar = null;
    }

    function getEpisodes(){

        var podcastId = podcasts.keys()[podcastsMenu.getSelected()];
        var podcast = podcasts[podcastId];

        var episodesRequest = new CompactLib.Utils.CompactRequest(WatchUi.loadResource(Rez.JsonData.connectionErrors));

        episodesRequest.requestShowProgress(
            Constants.URL_FEEDPARSER_ROOT,
            {"feedUrl" => podcast[Constants.PODCAST_URL], "max" => Constants.FEEDPARSER_MAX_EPISODES},
            method(:onEpisodes),
            null);
    }

    function onEpisodes(data, context) {

        var podcastId = podcasts.keys()[podcastsMenu.getSelected()];
        var podcast = podcasts[podcastId];

        menuEpisodes = {};

        var items = data.get("feed");

        if(items != null && items.size() > 0){
            var episodesMenu = new WatchUi.CheckboxMenu({:title => podcast[Constants.PODCAST_TITLE]});

            for(var i=0; i<items.size(); i++){
                var episode = Data.parseEpisode(items[i], podcastId);
                if(episode != null){
                    var episodeId = Data.genEpisodeId(episode);
                    menuEpisodes.put(episodeId, episode);
                    episodesMenu.addItem(new WatchUi.CheckboxMenuItem(episode[Constants.EPISODE_TITLE], "", episodeId, episodes.hasKey(episodeId), {}));
                }
            }

            WatchUi.switchToView(episodesMenu, new EpisodeSelectDelegate(self.weak()), WatchUi.SLIDE_LEFT);
        }else{
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoEpisodes); // FIXME
            alert.switchTo();
        }
    }

    function onPodcastBack(){
        Storage.setValue(Constants.STORAGE_EPISODES, episodes);
        var prompt = new Ui.CompactPrompt(Rez.Strings.confirmSync, method(:startSync), null);
        prompt.show();
    }

    function startSync(){
        WatchUi.popView(WatchUi.SLIDE_RIGHT);

        // Start sync
        Storage.setValue(Constants.STORAGE_MANUAL_SYNC, true);
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