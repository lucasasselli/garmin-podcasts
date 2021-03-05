using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer;

class ScrollText {

    const IDLE_TIME = 40;
    const CLIP_MARGIN = 10;
    const SCROLL_STEP = 2;

    private var text;
    private var font;
    private var margin;

    private var timer;
    private var idle;
    private var offset;
    private var tripDone;

    private var textWidth;
    private var scrollMax;
    private var scrollBase;

    private var init;

    function initialize(text, font, margin) {

        init = false;
        reset();

        self.text = text;
        self.font = font;
        self.margin = margin;
    }

    function draw(dc, x, y, focused) {

        if(!init){
            textWidth = dc.getTextWidthInPixels(text, font);
            scrollMax = dc.getWidth();
            scrollBase = x;
            init = true;
        }

        if(!focused){
            reset();
        }else{
            if (textWidth > (scrollMax - scrollBase)) {
                start();
            }
        }

        dc.setClip(x, 0, dc.getWidth() - x, dc.getHeight());
        dc.drawText(
            x + offset,
            y,
            font,
            text,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.clearClip();
    }

    function scroll() {
        if(idle < IDLE_TIME){
            // Wating to start scrolling
            idle++;
        }else{

            // Scroll
            offset -= SCROLL_STEP ;

            if (offset < SCROLL_STEP && tripDone){
                // Scroll complete, wait
                idle = 0;
                tripDone = false;
            }

            if (offset < -textWidth){
                // Exceeded screen... Back to beginning 
                offset = +textWidth;
                tripDone = true;
            }

            WatchUi.requestUpdate();
        }
    }

    function start() {
        if (timer == null) {
            timer = new Timer.Timer();
            timer.start(method(:scroll), 50, true);
        }
    }

    function reset() {
        if (timer != null) {
            timer.stop(); 
            timer = null;
        }
        offset = 0;
        idle = 0;
        tripDone = false;
    }
}