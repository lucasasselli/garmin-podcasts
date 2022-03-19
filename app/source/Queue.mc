using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Media;

using CompactLib.Ui;

class Queue extends WatchUi.CustomMenu {

    function initialize() {
        CustomMenu.initialize(Constants.CUSTOM_MENU_HEIGHT, Graphics.COLOR_BLACK, {});

        var episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});

        var sortDescending = Application.getApp().getProperty("settingQueueSortDescending") == 1;

        // Sort array by date
        episodes = Utils.sortArrayField(episodes.values(), Constants.EPISODE_DATE, sortDescending);

        // Add episodes to the menu
        for (var i = 0; i < episodes.size(); i++) {
            var mediaObj = Utils.getSafeMedia(episodes[i][Constants.EPISODE_MEDIA]);
            if(mediaObj != null){
                addItem(new QueueItem(episodes[i], episodes[i][Constants.EPISODE_IN_QUEUE] == true));
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
            WatchUi.loadResource(Rez.Strings.titleQueueMenu),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawFooter(dc){
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }
}

class QueueItem extends WatchUi.CustomMenuItem {

    const MARGIN = 8;
    const INNER_MARGIN = Constants.IMAGE_SIZE + MARGIN*2;

    private var checked;
    private var episode;

    private var centerX;
    private var centerY;

    private var titleText;
    private var podcastText;
    private var progress;
    private var artworkBitmap;
    private var tickBitmap;

    var scrollTimer;

    var init = false;

    var titleHeight;
    var podcastHeight;
    var yTextMargin;

    function initialize(episode, checked) {

        self.episode = episode;
        self.checked = checked;

        var refId = episode[Constants.EPISODE_MEDIA];
        var mediaObj = Utils.getSafeMedia(refId);

        var episodeTitle = mediaObj.getMetadata().title;
        var episodePodcast = mediaObj.getMetadata().artist;

        scrollTimer = new ScrollTimer();

        titleText = new ScrollText(self.weak(), episodeTitle, Graphics.FONT_SMALL, MARGIN);
        titleHeight = Graphics.getFontHeight(Graphics.FONT_SMALL);
        podcastText = new ScrollText(self.weak(), episodePodcast, Graphics.FONT_TINY, MARGIN);
        podcastHeight = Graphics.getFontHeight(Graphics.FONT_TINY);

        CustomMenuItem.initialize(Data.genEpisodeId(episode), {});
    }

    function draw(dc){
        if(!init){
            centerX = dc.getWidth()/2;
            centerY = dc.getHeight()/2;

            yTextMargin = (dc.getHeight() - titleHeight - podcastHeight - MARGIN)/2;

            artworkBitmap = Storage.getValue(Constants.ART_PREFIX + episode[Constants.EPISODE_PODCAST]);
            if(artworkBitmap == null){
                artworkBitmap = WatchUi.loadResource(Rez.Drawables.MissingArtworkIcon);
            }

            tickBitmap = WatchUi.loadResource(Rez.Drawables.TickIcon);

            if(episode[Constants.EPISODE_PROGRESS] != null){
                progress = episode[Constants.EPISODE_PROGRESS].toFloat()/episode[Constants.EPISODE_DURATION].toFloat();
            }else{
                progress = 0;
            }

            init = true;
        }

        // Clear the screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();

        // Draw item line
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.setPenWidth(1);
        dc.drawLine(0, 0, dc.getWidth(), 0);

        var yPos = yTextMargin + titleHeight/2;

        // Title
        titleText.draw(dc, INNER_MARGIN, yPos, isFocused());
        yPos += titleHeight/2 + podcastHeight/2;

        // Podcast
        podcastText.draw(dc, INNER_MARGIN, yPos, isFocused());
        yPos += podcastHeight/2 + MARGIN;

        // Progress
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_WHITE);
        dc.drawLine(INNER_MARGIN, yPos, dc.getWidth() - 8, yPos);
        dc.setPenWidth(3);
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_WHITE);
        dc.drawLine(INNER_MARGIN, yPos, INNER_MARGIN + progress*(dc.getWidth() - INNER_MARGIN - 8), yPos);

        // Draw image
        dc.drawBitmap(MARGIN, centerY - Constants.IMAGE_SIZE/2, artworkBitmap);

        if(checked){
            dc.drawBitmap(MARGIN + Constants.IMAGE_SIZE/2 - 16, centerY - 16, tickBitmap);
        }
    }

    function check(){
        checked = ! checked;
        WatchUi.requestUpdate();
        return checked;
    }
}

class QueueDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var episodes = StorageHelper.get(Constants.STORAGE_EPISODES, {});

        if (item.check()) {
            episodes[item.getId()][Constants.EPISODE_IN_QUEUE] = true;
        } else {
            episodes[item.getId()][Constants.EPISODE_IN_QUEUE] = false;
        }

        Storage.setValue(Constants.STORAGE_EPISODES, episodes);
    }

    function onBack(){
        var prompt = new Ui.CompactPrompt(Rez.Strings.confirmPlayback, method(:startPlayback), method(:exitView));
        prompt.show();
        return false;
    }

    function startPlayback(){
        // NOTE: Popping the view before starting playback causes problems...
        Media.startPlayback(null);
    }

    function exitView(){
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}