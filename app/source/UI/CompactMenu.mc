using Toybox.WatchUi;

class CompactMenu {

    hidden var items;
    hidden var title;
    hidden var menu;

    hidden var selected;

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

    function get(){
        if(menu == null){
            menu = new CompactMenuView({:title=> StringHelper.get(title)}, items);
            build();
        }
        return [menu, new CompactMenuDelegate(method(:onSelect), backCallback)];
    }

    function preShow(){
        if(menu == null){
            menu = new CompactMenuView({:title=> StringHelper.get(title)}, items);
            build();
        }
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

    function initialize(options, items){
        self.items = items;
        Menu2.initialize(options);

    }

    function onShow() {
        for(var i=0; i<items.size(); i++){
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
        }else{
            backCallback.invoke();
        }
		return true;
	}
}