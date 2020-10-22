using Toybox.WatchUi;

class Settings extends CompactMenu {

	function initialize(){
		CompactMenu.initialize(Rez.Strings.settings);
	}
	
	function build(){
		add(Rez.Strings.settingEpisodesPerPodcastTitle, method(:getEpisodesPerPodcast), method(:callbackEpisodesPerPodcast));
	}

	function getEpisodesPerPodcast(){
    	return Application.getApp().getProperty("settingEpisodes").toString();
	}

	function callbackEpisodesPerPodcast(){
		var settingEpisodesMenu = new Rez.Menus.SettingsEpisodes();
		WatchUi.pushView(settingEpisodesMenu, new SettingsEpisodesDelegate(), WatchUi.SLIDE_LEFT); 
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