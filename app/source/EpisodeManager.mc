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
        add(Rez.Strings.menuEpisodesDownload, null, method(:callbackEpisodeDownload));
        add(Rez.Strings.menuEpisodesDelete, method(:getDeleteLabel), method(:callbackEpisodeDelete));
    }

    // Download
    function callbackEpisodeDownload(){
        var episodeDownload = new EpisodeDownload();
        episodeDownload.show();
    }

    // Delete
    function callbackEpisodeDelete() {
        var episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
        var podcasts = StorageHelper.get(Constants.STORAGE_SUBSCRIBED, {});

        var downloadedCount = 0;

        var episodesMenu = new WatchUi.Menu2({:title => Rez.Strings.menuEpisodesDelete});
        var menuEpisodes = {};

        for(var i=0; i<episodes.size(); i++){
            var episode = episodes.values()[i];
            var podcastTitle = "";

            if(episode[Constants.EPISODE_MEDIA] != null){

                // If podcast still exists
                // FIXME: Is this a valid scenario?
                if(podcasts.hasKey(episode[Constants.EPISODE_PODCAST])){
                    podcastTitle = podcasts[episode[Constants.EPISODE_PODCAST]][Constants.PODCAST_TITLE];
                }

                if(episode[Constants.EPISODE_MEDIA] != null){
                    downloadedCount++;
                    episodesMenu.addItem(new WatchUi.MenuItem(episode[Constants.EPISODE_TITLE], podcastTitle, episodes.keys()[i], {}));
                }
            }
        }
        if (downloadedCount > 0) {
            // Episodes downloaded
            WatchUi.pushView(episodesMenu, new EpisodeDeleteSelectDelegate(episodesMenu), WatchUi.SLIDE_LEFT);
        } else {
            // No episodes
            var alert = new Ui.CompactAlert(Rez.Strings.errorNoQueueEpisodes);
            alert.show();
        }
    }

    function getDeleteLabel(){
        var count = MainMenu.getDownloadedSize();
        return count + " " + WatchUi.loadResource(Rez.Strings.episodes);
    }
}

class EpisodeDeleteSelectDelegate extends WatchUi.Menu2InputDelegate {

    private var toDelete = [];
    private var menu;

    function initialize(menu) {
        self.menu = menu;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        menu.deleteItem(menu.findItemById(item.getId()));
        toDelete.add(item.getId());
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
            exitView();
        }
    }

    function callbackDelete(){

        // Remove deleted episodes
        var episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});
        for(var i=0; i<toDelete.size(); i++){
            episodes.remove(toDelete[i]);
        }
        Storage.setValue(Constants.STORAGE_EPISODES, episodes);

        // Trigger data cleanup
        Utils.purgeBadMedia();

        exitView();
    }

    function exitView(){
        // Just exit
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onBack(){
        deletePrompt();
    }
}