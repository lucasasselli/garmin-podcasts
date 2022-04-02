using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Cryptography;
using Toybox.StringUtil;
using Toybox.Application.Storage;

using CompactLib.Ui;

class EpisodeDownload {

    var loadingShown;

    var podcasts;
    var view;

    var progressBar;

    var saved;
    var episodes;
    var menuEpisodes;

    function initialize(){
        saved = StorageHelper.get(Constants.STORAGE_EPISODES, {});
        episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
    }

    function show(){
        $.podcastsProvider.get(method(:podcastsDone));
    }

    function podcastsDone(hasProgress, podcasts){
        self.podcasts = podcasts;

        if(podcasts != null && podcasts.size() > 0){
            view = new Ui.CompactMenu(Rez.Strings.titleSelectEpisodesMenu);
            view.setBackCallback(method(:onPodcastBack));

            var podcastIds = podcasts.keys();

            for(var i=0; i<podcastIds.size(); i++){
                view.add(podcasts[podcastIds[i]][Constants.PODCAST_TITLE], method(:getSelected), method(:getEpisodes));
            }

        }else{
            view = new Ui.CompactAlert(Rez.Strings.errorNoSubscriptions);
        }

        if(hasProgress == null || hasProgress == false){
            view.show();
        }else{
            view.switchTo();
        }
    }

    function getSelected(){
        var podcastId = podcasts.keys()[view.getSelected()];
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

        var podcastId = podcasts.keys()[view.getSelected()];
        var podcast = podcasts[podcastId];

        var episodesRequest = new CompactLib.Utils.CompactRequest(WatchUi.loadResource(Rez.JsonData.connectionErrors));

        episodesRequest.requestShowProgress(
            Constants.URL_FEEDPARSER_ROOT,
            {"feedUrl" => podcast[Constants.PODCAST_URL], "max" => Constants.FEEDPARSER_MAX_EPISODES},
            method(:onEpisodes),
            null);
    }

    function onEpisodes(data, context) {

        var podcastId = podcasts.keys()[view.getSelected()];
        var podcast = podcasts[podcastId];

        var episodesMenu = new WatchUi.CheckboxMenu({:title => podcast[Constants.PODCAST_TITLE]});
        menuEpisodes = {};

        var items = data.get("feed");
        if(items != null){
            for(var i=0; i<items.size(); i++){
                // FIXME: Might never be null!
                var episode = Data.parseEpisode(items[i], podcastId);
                if(episode != null){
                    var episodeId = Data.genEpisodeId(episode);
                    menuEpisodes.put(episodeId, episode);
                    episodesMenu.addItem(new WatchUi.CheckboxMenuItem(episode[Constants.EPISODE_TITLE], "", episodeId, episodes.hasKey(episodeId), {}));
                }
            }

        }

        if(menuEpisodes.size() > 0){
            WatchUi.switchToView(episodesMenu, new EpisodeSelectDelegate(self.weak()), WatchUi.SLIDE_LEFT);
        }else{
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoPodcastEpisodes);
            alert.switchTo();
        }
    }

    function onPodcastBack(){
        Storage.setValue(Constants.STORAGE_EPISODES, episodes);
        var prompt = new Ui.CompactPrompt(Rez.Strings.confirmSync, method(:startSync), method(:exitView));
        prompt.show();
    }

    function startSync(){
        WatchUi.popView(WatchUi.SLIDE_RIGHT);

        // Start sync
        Storage.setValue(Constants.STORAGE_MANUAL_SYNC, true);
        Communications.startSync();
    }

    function exitView(){
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
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
                    // If the episode is saved, use it to avoid losing media
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