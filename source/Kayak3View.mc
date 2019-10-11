//using Toybox.WatchUi as Ui;
//using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Lang as Lang;
using Toybox.ActivityRecording as Record;
using Toybox.Timer as Timer;
using Toybox.Math as Math;
using Toybox.Activity as Activity;
using Toybox.Position as Position;
using Toybox.Attention as Attention;
using Toybox.Graphics as Gfx;

var MAX_PAGE_NUM = 3;

var dataTimer = new Timer.Timer();

var stringColor = null;

class Kayak3View extends Ui.View {

    function initialize() {
        View.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        
        var string = "NumOfFieldsDisp"+(pageNum+1).toString();
    	var numOfFields = App.getApp().getProperty(string);
    	
    	if (numOfFields == 1) {
        setLayout(Rez.Layouts.OneFields(dc));
        }
        else if (numOfFields == 2) {
        setLayout(Rez.Layouts.TwoFields(dc));
        }
        else if (numOfFields == 3) {
        setLayout(Rez.Layouts.ThreeFields(dc));
        }
        else if (numOfFields == 4) {
        setLayout(Rez.Layouts.FourFields(dc));
        }        
        
    	//! Start a timer callback to update data and layout
		dataTimer.start( method(:timerCallback), 1000, true );
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
    	if (pageChange) {
    		var string = "NumOfFieldsDisp"+(pageNum+1).toString();
	    	Sys.println(string);
	    	var numOfFields = App.getApp().getProperty(string);
	    	Sys.println(numOfFields);
	    	
	    	if (numOfFields == 1) {
	        setLayout(Rez.Layouts.OneFields(dc));
	        }
	        else if (numOfFields == 2) {
	        setLayout(Rez.Layouts.TwoFields(dc));
	        }
	        else if (numOfFields == 3) {
	        setLayout(Rez.Layouts.ThreeFields(dc));
	        }
	        else if (numOfFields == 4) {
	        setLayout(Rez.Layouts.FourFields(dc));
	        }
    		pageChange = false;
    	}

    	var object = new Kayak3DataRetreival();

    	var string = "NumOfFieldsDisp"+(pageNum+1).toString();
    	//Sys.println(string);
    	var numOfFields = App.getApp().getProperty(string);
    	//Sys.println(numOfFields);
    	for (var i = 1; i <= numOfFields; i++) {
    		string = "DataField" + i.toString() + "Disp"+(pageNum+1).toString();
    	
    		var dataField_prop = App.getApp().getProperty(string);
    		Sys.println(dataField_prop);
    		var string_value = "DataField" + i.toString() + "Value";
    		var string_label = "DataField" + i.toString() + "Label";
	        var string_value_address = View.findDrawableById(string_value);
	        var string_label_address = View.findDrawableById(string_label);
	        
	        object.getDataFieldValues(dataField_prop);
        
        	var value = object.value;
        	var label = object.label;
        	Sys.println(value);
        	//Sys.println(label);
        	//Sys.println(string_value);
        	//Sys.println(string_label);
        	//Sys.println(string_value_address);
        	//Sys.println(string_label_address);
        	string_value_address.setText(value);
        	string_label_address.setText(label);
        	
        	if (!session.isRecording()) {
				string_value_address.setColor(Gfx.COLOR_DK_BLUE);
        		string_label_address.setColor(Gfx.COLOR_DK_BLUE);
        	}
        	else {
        		string_value_address.setColor(Gfx.COLOR_BLACK);
        		string_label_address.setColor(Gfx.COLOR_BLACK);
        	}
        	
	    }
    
        View.onUpdate(dc);
        
        object.getGPSStatus();
        if (object.gpsstatus <= Position.QUALITY_POOR) {
	    	//setLayout(Rez.Layouts.GPSStatusLayout(dc));
	    	//var GPSStatusID = View.findDrawableById("GPSStatus");
			//GPSStatusID.setText("GPS");
			//GPSStatusID.setColor(Gfx.COLOR_RED);
			//var GPSBackground = new Rez.Drawables.GPSStatusDrawable();
			//GPSBackground.draw(dc);
			dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_WHITE);
			dc.drawText(dc.getWidth()/2, 0, Gfx.FONT_MEDIUM, "GPS", Gfx.TEXT_JUSTIFY_CENTER);
			//dc.getHeight() - dc.getFontHeight(Gfx.FONT_MEDIUM))/2
	    }
        
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }
    
    function timerCallback() {
        Ui.requestUpdate();            
    }

}
