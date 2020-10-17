using Toybox.WatchUi;

class SettingsMainDelegate extends WatchUi.Menu2InputDelegate {

    function onSelect(item) {  
		var settingEpisodesMenu = new Rez.Menus.SettingsEpisodes();
		WatchUi.pushView(settingEpisodesMenu, new SettingsEpisodesDelegate(), WatchUi.SLIDE_LEFT); 
    } 
}
   
class SettingsEpisodesDelegate extends WatchUi.Menu2InputDelegate {

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
}