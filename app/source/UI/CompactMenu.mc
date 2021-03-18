using Toybox.WatchUi;

class CompactMenu {

    var selected;

    hidden var items;
    hidden var title;
    hidden var menu;

    hidden var backCallback;

    function initialize(title){
        items = [];
        self.title = title;
    }

    function setBackCallback(callback){
        self.backCallback = callback;
    }

    function build(){

    }

    function preShow(){
        if(menu == null){
            menu = new CompactMenuView({:title=> StringHelper.get(title)}, items, self.weak());
            build();
        }
    }

    function get(){
        preShow();
        return [menu, new CompactMenuDelegate(method(:onSelect), backCallback)];
    }

    function show(){
        preShow();
        WatchUi.pushView(menu, new CompactMenuDelegate(method(:onSelect), backCallback), WatchUi.SLIDE_LEFT);
    }

    function switchTo(){
        preShow();
        WatchUi.switchToView(menu, new CompactMenuDelegate(method(:onSelect), backCallback), WatchUi.SLIDE_LEFT);
    }

    function add(labelBuilder, sublabelBuilder, callback){
        items.add([labelBuilder, sublabelBuilder, callback]);
    }

    function onSelect(item){
        selected = item;
        items[item][2].invoke();
    }

    function getSelected(){
        return selected;
    }
}

class CompactMenuView extends WatchUi.Menu2 {

    hidden var items;
    hidden var init;
    hidden var parentRef;

    function initialize(options, items, parentRef){
        self.items = items;
        self.parentRef = parentRef;
        Menu2.initialize(options);
    }

    function onShow() {
        if(parentRef.stillAlive()){
            var parent = parentRef.get();
            for(var i=0; i<items.size(); i++){
                parent.selected = i;
                var item = new WatchUi.MenuItem(
                    StringHelper.get(items[i][0]),
                    StringHelper.get(items[i][1]),
                    i,
                    {});
                if(init){
                    updateItem(item, i);     	
                } else {
                    addItem(item);
                }
            }
            init = true;
        }
    }
}

class CompactMenuDelegate extends WatchUi.Menu2InputDelegate {

    hidden var selectCallback;
    hidden var backCallback;

    function initialize(selectCallback, backCallback) {
        self.selectCallback = selectCallback;
        self.backCallback = backCallback;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        selectCallback.invoke(item.getId());
    }

	function onBack(){
        if(backCallback == null){
    	    WatchUi.popView(WatchUi.SLIDE_RIGHT);    	
		    return true;
        }else{
            return backCallback.invoke();
        }
	}
}