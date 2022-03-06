using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Communications;
using Toybox.Media;

using CompactLib.Ui;

class EpisodeManager extends Ui.CompactMenu {

    function initialize(){
        CompactMenu.initialize(Rez.Strings.menuEpisodes);
    }

    function build(){
        add(Rez.Strings.menuEpisodesDownload, null, method(:callbackDownload));
        add(Rez.Strings.menuEpisodesDelete, null, method(:callbackDelete));
    }

    // Download
    function callbackDownload(){
        var episodeDownload = new EpisodeDownload();
        episodeDownload.show();
    }

    // Delete
    function callbackDelete() {
        var episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
        var podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});

        var downloadedCount = 0;

        var episodesMenu = new WatchUi.CheckboxMenu({:title => Rez.Strings.menuEpisodesDelete});
        var menuEpisodes = {};

        for(var i=0; i<episodes.size(); i++){
            var episode = episodes.values()[i];
            var podcastTitle = "";

            if(episode[Constants.EPISODE_MEDIA] != null){
                downloadedCount++;

                // If podcast still exists
                if(podcasts.hasKey(episode[Constants.EPISODE_PODCAST])){
                    podcastTitle = podcasts[episode[Constants.EPISODE_PODCAST]][Constants.PODCAST_TITLE];
                }

                episodesMenu.addItem(new WatchUi.CheckboxMenuItem(episode[Constants.EPISODE_TITLE], podcastTitle, episodes.keys()[i], false, {}));
            }
        }
        if (downloadedCount > 0) {
            // Episodes downloaded
            WatchUi.pushView(episodesMenu, new EpisodeDeleteSelectDelegate(), WatchUi.SLIDE_LEFT);
        } else {
            // No episodes
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoQueueEpisodes);
            alert.show();
        }
    }
}

class EpisodeDeleteSelectDelegate extends WatchUi.Menu2InputDelegate {

    var toDelete = {};

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if (item.isChecked()) {
            toDelete.put(item.getId(), null);
        } else {
            toDelete.remove(item.getId());
        }
    }

    function onDone() {
        if(toDelete.size() > 0){
            // ... something to delete, ask user to confirm
            var prompt = new Ui.CompactPrompt(Rez.Strings.confirmDelete, method(:delete), method(:exitView));
            prompt.show();
        }else{
            // Just exit
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
    }

    function delete(){

        // Remove deleted episodes
        var episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
        for(var i=0; i<toDelete.size(); i++){
            episodes.remove(toDelete.keys()[i]);
        }
        Storage.setValue(Constants.STORAGE_EPISODES, episodes);

        // Trigger data cleanup
        Utils.purgeBadMedia();

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function exitView(){
        // Just exit
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}