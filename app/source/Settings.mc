using Toybox.WatchUi;

using CompactLib.Ui;

class Settings extends Ui.CompactMenu {

    function initialize(){
        CompactMenu.initialize(Rez.Strings.menuSettings);
    }

    function build(){
        add(Rez.Strings.settingPodcastServiceTitle, method(:getPodcastService), method(:callbackPodcastService));
        add(Rez.Strings.settingSyncModeTitle, method(:getSyncMode), method(:callbackSyncMode));
        add(Rez.Strings.settingEpisodesPerPodcastTitle, method(:getEpisodesPerPodcast), method(:callbackEpisodesPerPodcast));
        add(Rez.Strings.settingEpisodesMaxTitle, method(:getEpisodesMax), method(:callbackEpisodesMax));
    }

    function getPodcastService(){
        var service = Application.getApp().getProperty("settingPodcastService");
        if(service == 0){
            return WatchUi.loadResource(Rez.Strings.none);
        }else{
            return WatchUi.loadResource(Rez.Strings.gPodder);
        }
    }

    function getSyncMode(){
        var mode = Application.getApp().getProperty("settingSyncMode");
        if(mode == 0){
            return WatchUi.loadResource(Rez.Strings.manual);
        }else{
            return WatchUi.loadResource(Rez.Strings.mostRecent);
        }
    }

    function callbackPodcastService(){
        var menu = new Rez.Menus.SettingPodcastService();
        WatchUi.pushView(menu, new SettingsPodcastServiceDelegate(), WatchUi.SLIDE_LEFT);
    }

    function callbackSyncMode(){
        var menu = new Rez.Menus.SettingSyncMode();
        WatchUi.pushView(menu, new SettingsSyncModeDelegate(), WatchUi.SLIDE_LEFT);
    }

    function getEpisodesPerPodcast(){
        return Application.getApp().getProperty("settingEpisodes").toString();
    }

    function callbackEpisodesPerPodcast(){
        var menu = new Rez.Menus.SettingEpisodes();
        WatchUi.pushView(menu, new SettingsEpisodesDelegate(), WatchUi.SLIDE_LEFT);
    }

    function getEpisodesMax(){
        return Application.getApp().getProperty("settingEpisodesMax").toString();
    }

    function callbackEpisodesMax(){
        var menu = new Rez.Menus.SettingEpisodesMax();
        WatchUi.pushView(menu, new SettingsEpisodesMaxDelegate(), WatchUi.SLIDE_LEFT);
    }

}

class SettingsPodcastServiceDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
           var app = Application.getApp();
        if (item.getId() == :gPodder) {
               app.setProperty("settingPodcastService", 1);
        } else {
            app.setProperty("settingPodcastService", 0);
        }

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

class SettingsSyncModeDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
           var app = Application.getApp();
        if (item.getId() == :manual) {
               app.setProperty("settingSyncMode", 0);
        } else {
            app.setProperty("settingSyncMode", 1);
        }

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

class SettingsEpisodesDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
           var app = Application.getApp();
        if (item.getId() == :two_episodes) {
               app.setProperty("settingEpisodes", 2);
        } else if (item.getId() == :five_episodes) {
            app.setProperty("settingEpisodes", 5);
        } else {
            app.setProperty("settingEpisodes", 1);
        }

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onBack(){
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}

class SettingsEpisodesMaxDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
           var app = Application.getApp();
        if (item.getId() == :twenty_episodes) {
               app.setProperty("settingEpisodesMax", 20);
        } else if (item.getId() == :fifty_episodes) {
            app.setProperty("settingEpisodesMax", 50);
        } else {
            app.setProperty("settingEpisodesMax", 10);
        }

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onBack(){
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}