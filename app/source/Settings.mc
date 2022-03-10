using Toybox.WatchUi;

using CompactLib.Ui;

class Settings extends Ui.CompactMenu {

    function initialize(){
        CompactMenu.initialize(Rez.Strings.menuSettings);
    }

    function build(){
        add(Rez.Strings.settingPodcastServiceTitle, method(:getPodcastService), method(:callbackPodcastService));
        add(Rez.Strings.settingStorageTitle, method(:getStorage), method(:callbackStorage));
    }

    function getPodcastService(){
        var service = Application.getApp().getProperty("settingPodcastService");
        switch(item.getId()){
            case :gPodder:
            return WatchUi.loadResource(Rez.Strings.gPodder);

            case :nextcloud:
            return WatchUi.loadResource(Rez.Strings.nextcloud);

            default:
            return WatchUi.loadResource(Rez.Strings.none);
        }
    }

    function callbackPodcastService(){
        var menu = new Rez.Menus.SettingPodcastService();
        WatchUi.pushView(menu, new SettingsPodcastServiceDelegate(), WatchUi.SLIDE_LEFT);
    }

    function getStorage(){
        var cacheStatistics = Media.getCacheStatistics();
        var used = ((cacheStatistics.size / cacheStatistics.capacity)*100).toNumber();
        return used.toString() + "% used";
    }

    function callbackStorage(){
        // TODO: Implement some extra info?
    }
}

class SettingsPodcastServiceDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var app = Application.getApp();
        switch(item.getId()){
            case :gPodder:
            app.setProperty("settingPodcastService", PodcastsProviderWrapper.PODCAST_SERVICE_GPODDER);
            break;

            case :nextcloud:
            app.setProperty("settingPodcastService", PodcastsProviderWrapper.PODCAST_SERVICE_NEXTCLOUD);
            break;

            default:
            app.setProperty("settingPodcastService", PodcastsProviderWrapper.PODCAST_SERVICE_LOCAL);
            break;
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}