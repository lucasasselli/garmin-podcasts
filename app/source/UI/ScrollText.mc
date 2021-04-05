using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer;

class ScrollTimer {

    private var timer;
    private var subscribers = [];

    function initialize(){

    }

    function register(ref){
        if(subscribers.indexOf(ref) < 0){
            subscribers.add(ref);
        }
        
        start();
    }

    function unregister(ref){
        if(subscribers.indexOf(ref) >= 0){
            subscribers.remove(ref);
        }
    }

    function start() {
        if (timer == null) {
            timer = new Timer.Timer();
            timer.start(method(:trigger), 50, true);
        }
    }

    function trigger(){
        for(var i=0; i<subscribers.size(); i++){
            if(subscribers[i].stillAlive()){
                (subscribers[i].get()).scroll();
            }else{
                // Remove dead subscriber
                subscribers.remove(subscribers[i]);
            }
        }

        // Kill the timer if all subscribers are gone!
        if(subscribers.size() == 0){
            reset();
        }

        // Update GUI only once
        WatchUi.requestUpdate();
    }

    function reset() {
        if (timer != null) {
            timer.stop(); 
            timer = null;
        }
    }

}

class ScrollText {

    const IDLE_TIME = 40;
    const CLIP_MARGIN = 10;
    const SCROLL_STEP = 2;

    private var text;
    private var font;
    private var margin;

    private var idle;
    private var offset;
    private var tripDone;

    private var textWidth;
    private var scrollMax;
    private var scrollBase;

    private var init;

    private var parentRef;

    function initialize(parentRef, text, font, margin) {

        init = false;
        reset();

        self.parentRef = parentRef;
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
            if(parentRef.stillAlive()){
                (parentRef.get()).scrollTimer.unregister(self.weak());
            }
            reset();
        }else{
            if (textWidth > (scrollMax - scrollBase)) {
                if(parentRef.stillAlive()){
                    (parentRef.get()).scrollTimer.register(self.weak());
                }
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

        // If parent is gone, kill timers!
        if(!parentRef.stillAlive()){
            reset();
            return;
        }

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
        }
    }

    function reset() {
        offset = 0;
        idle = 0;
        tripDone = false;
    }
}