using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;

class FallbackPicker extends WatchUi.Picker {
    const mCharacterSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789";
    hidden var mTitleText;
    hidden var mFactory;
    hidden var defaultString;

    function initialize(defaultString) {
        mFactory = new CharacterFactory(mCharacterSet, {:addOk=>true});
        mTitleText = "";

        self.defaultString = defaultString;

        mTitle = new WatchUi.Text({:text=>defaultString, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});

        Picker.initialize({:title=>mTitle, :pattern=>[mFactory], :defaults=>null});
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }

    function addCharacter(character) {
        mTitleText += character;
        mTitle.setText(mTitleText);
    }

    function removeCharacter() {
        mTitleText = mTitleText.substring(0, mTitleText.length() - 1);

        if(0 == mTitleText.length()) {
            mTitle.setText(title);
        }
        else {
            mTitle.setText(mTitleText);
        }
    }

    function getText() {
        return mTitleText.toString();
    }

    function isDone(value) {
        return mFactory.isDone(value);
    }
}

class CharacterFactory extends WatchUi.PickerFactory {
    hidden var mCharacterSet;
    const DONE = -1;

    function initialize(characterSet, options) {
        PickerFactory.initialize();
        mCharacterSet = characterSet;
    }

    function getIndex(value) {
        var index = mCharacterSet.find(value);
        return index;
    }

    function getSize() {
        return mCharacterSet.length() + 1;
    }

    function getValue(index) {
        if(index == mCharacterSet.length()) {
            return DONE;
        }
        return mCharacterSet.substring(index, index+1);
    }

    function getDrawable(index, selected) {
        if(index == mCharacterSet.length()) {
            return new WatchUi.Text( {:text=>Rez.Strings.search, :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_LARGE, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER } );
        }else{
            return new WatchUi.Text( {:text=>getValue(index), :color=>Graphics.COLOR_WHITE, :font=> Graphics.FONT_LARGE, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER } );
        }
    }

    function isDone(value) {
        return (value == DONE);
    }
}