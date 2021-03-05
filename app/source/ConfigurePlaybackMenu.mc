using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Media;

class ConfigurePlaybackMenu extends WatchUi.CustomMenu {

    function initialize() {
        CustomMenu.initialize(Constants.CUSTOM_MENU_HEIGHT, Graphics.COLOR_WHITE, {});
        
        // Get the current stored playlist.
        var currentPlaylist = {};
        var playlist = StorageHelper.get(Constants.STORAGE_PLAYLIST, []);
        for (var i = 0; i < playlist.size(); ++i) {
            currentPlaylist[playlist[i]] = true;
        }

        // For each song in the playlist, precheck the item when adding it to the menu
        var episodes = StorageHelper.get(Constants.STORAGE_SAVED, []);

        for (var i = 0; i < episodes.size(); i++) {
            var refId = episodes[i][Constants.EPISODE_MEDIA];       	
            var mediaObj = Utils.getSafeMedia(refId);

            if(mediaObj != null){
	            var episodeTitle = mediaObj.getMetadata().title;
	            var episodePodcast = mediaObj.getMetadata().artist;
	            
	            // addItem(new WatchUi.CheckboxMenuItem(episodeTitle, episodePodcast, refId, currentPlaylist.hasKey(refId), {}));
                addItem(new PlaybackMenuItem(episodes[i], currentPlaylist.hasKey(refId)));
            }
        }
    }

    function drawTitle(dc){
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        dc.drawText(
            dc.getWidth()/2,
            dc.getHeight()/2,
            Graphics.FONT_SMALL,
            "Queue", // FIXME
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawFooter(dc){
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }
}

class PlaybackMenuItem extends WatchUi.CustomMenuItem {

    private var checked = false;
    private var episode;

    var refId;
    var mediaObj;
    var artwork;

    var titleText;
    var podcastText;

    const MARGIN = 8;
    const INNER_MARGIN = Constants.IMAGE_SIZE + MARGIN*2;

    function initialize(episode, checked) {
        self.episode = episode;
        self.checked = checked;

        refId = episode[Constants.EPISODE_MEDIA];       	

        mediaObj = Utils.getSafeMedia(refId);
        artwork = Storage.getValue(Constants.ART_PREFIX + episode[Constants.EPISODE_PODCAST]);

        var episodeTitle = mediaObj.getMetadata().title;
        var episodePodcast = mediaObj.getMetadata().artist;

        titleText = new ScrollText(episodeTitle, Graphics.FONT_SMALL, MARGIN);
        podcastText = new ScrollText(episodePodcast, Graphics.FONT_TINY, MARGIN);

        CustomMenuItem.initialize(refId, {});
    }

    function draw(dc){

        var centerX = dc.getWidth()/2;
        var centerY = dc.getHeight()/2;

        var episodeTitle = mediaObj.getMetadata().title;
        var episodePodcast = mediaObj.getMetadata().artist;

        var tickBitmap = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.TickIcon,
            :locX=> MARGIN + Constants.IMAGE_SIZE/2 - 16,
            :locY=> centerY - 16
        });

        // Clear the screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();

        // Draw item line
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.setPenWidth(1);
        dc.drawLine(0, 0, dc.getWidth(), 0);

        // Title
        titleText.draw(dc, INNER_MARGIN, centerY - 24, isFocused());

        // Podcast
        podcastText.draw(dc, INNER_MARGIN, centerY + 4, isFocused());

        var progress;
        if(episode[Constants.EPISODE_PROGRESS] != null){
            progress = episode[Constants.EPISODE_PROGRESS].toFloat()/episode[Constants.EPISODE_DURATION].toFloat();
        }else{
            progress = 0;
        }
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_WHITE);
        dc.drawLine(INNER_MARGIN, centerY +24, dc.getWidth() - 8, centerY + 24);
        dc.setPenWidth(3);
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_WHITE);
        dc.drawLine(INNER_MARGIN, centerY +24, INNER_MARGIN + progress*(dc.getWidth() - INNER_MARGIN - 8), centerY + 24);

        if(artwork != null){
            dc.drawBitmap(MARGIN, centerY - Constants.IMAGE_SIZE/2, artwork);
        }else{
            var missingBitmap = new WatchUi.Bitmap({
                :rezId=>Rez.Drawables.MissingArtworkIcon,
                :locX=> MARGIN,
                :locY=> centerY - Constants.IMAGE_SIZE/2
            });
            missingBitmap.draw(dc);
        }

        if(checked){
            tickBitmap.draw(dc);
        }
    }

    function check(){
        checked = ! checked;
        WatchUi.requestUpdate();
        return checked;
    }
}

class ConfigurePlaybackMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var playlist = StorageHelper.get(Constants.STORAGE_PLAYLIST, []);

        // When an item is selected, add or remove it from the system playlist
        if (item.check()) {
            playlist.add(item.getId());
        } else {
            playlist.remove(item.getId());
        }

        Storage.setValue(Constants.STORAGE_PLAYLIST, playlist);
    }

	function onBack(){
		WatchUi.pushView(new WatchUi.Confirmation(WatchUi.loadResource(Rez.Strings.confirmPlayback)), new ConfirmPlaybackBackDelegate(), WatchUi.SLIDE_LEFT);
        return false;
	}
}

class ConfirmPlaybackBackDelegate extends WatchUi.ConfirmationDelegate {

    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {    	
		if(response == CONFIRM_YES){		
            Media.startPlayback(null);
		}else{
            WatchUi.popView(WatchUi.SLIDE_LEFT);
        }
	}
}
