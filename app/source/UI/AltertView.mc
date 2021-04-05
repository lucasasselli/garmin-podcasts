using Toybox.Graphics;
using Toybox.WatchUi;

class AlertView extends WatchUi.View {

    private var msg;

    function initialize(x) {
        msg = StringHelper.get(x);
        View.initialize();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        dc.drawText(dc.getWidth() / 2,
                    dc.getHeight() / 2,
                    Graphics.FONT_SMALL,
                    msg,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}