using Toybox.WatchUi;

class Settings extends CompactMenu {

	function initialize(){
		CompactMenu.initialize(Rez.Strings.settings);
	}
	
	function build(){
		add(Rez.Strings.settingServiceTitle, method(:getService), method(:callbackService));
		add(Rez.Strings.settingEpisodesPerPodcastTitle, method(:getEpisodesPerPodcast), method(:callbackEpisodesPerPodcast));
		add(Rez.Strings.settingEpisodesMaxTitle, method(:getEpisodesMax), method(:callbackEpisodesMax));
	}

	function getService(){
        var service = Application.getApp().getProperty("settingService");
        if(service == 0){
    	    return WatchUi.loadResource(Rez.Strings.none);
        }else{
    	    return WatchUi.loadResource(Rez.Strings.gPodder);
        }
	}

	function callbackService(){
		var menu = new Rez.Menus.SettingService();
		WatchUi.pushView(menu, new SettingsServiceDelegate(), WatchUi.SLIDE_LEFT); 
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

class SettingsServiceDelegate extends WatchUi.Menu2InputDelegate {

	function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
       	var app = Application.getApp();
        if (item.getId() == :gPodder) {
       		app.setProperty("settingService", 1);
		} else {
			app.setProperty("settingService", 0);
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