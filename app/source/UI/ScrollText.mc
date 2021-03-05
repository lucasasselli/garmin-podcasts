using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer;

class ScrollText {

    const IDLE_TIME = 40;
    const CLIP_MARGIN = 10;

    private var text;
    private var font;
    private var margin;

    private var timer;
    private var idle;
    private var offset;

    private var text_width;
    private var text_height;
    private var scroll_max;
    private var scroll_base;

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
            text_width = dc.getTextWidthInPixels(text, font);
            text_height = dc.getFontHeight(font);
            scroll_max = dc.getWidth();
            scroll_base = x;
            init = true;
        }

        if(!focused){
            reset();
        }else{
            if (text_width > (scroll_max - scroll_base)) {
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
            offset += 1 ;

            if (offset == 0){
                // Scroll complete, wait
                idle = 0;
            }

            if (offset > scroll_max){
                // Exceeded screen... Back to beginning 
                offset = -text_width;
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
    }
}