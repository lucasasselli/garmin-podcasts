using Toybox.WatchUi;

using CompactLib.Ui;

class Settings extends Ui.CompactMenu {

    function initialize(){
        CompactMenu.initialize(Rez.Strings.menuSettings);
    }

    function build(){
        add(Rez.Strings.settingPodcastServiceTitle, method(:getPodcastService), method(:callbackPodcastService));
    }

    function getPodcastService(){
        var service = Application.getApp().getProperty("settingPodcastService");
        if(service == 0){
            return WatchUi.loadResource(Rez.Strings.none);
        }else{
            return WatchUi.loadResource(Rez.Strings.gPodder);
        }
    }

    function callbackPodcastService(){
        var menu = new Rez.Menus.SettingPodcastService();
        WatchUi.pushView(menu, new SettingsPodcastServiceDelegate(), WatchUi.SLIDE_LEFT);
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