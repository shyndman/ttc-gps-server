ttc = {
	init: function() {
		// Initialize the console
		ttc.initConsole();
		
		// Initialize the map
		ttc.initMap();
		
		// Find the user's location
		ttc.findLocation();
	},
	
	/** Inits console functions to defaults if they don't exist. */
	initConsole: function() {
		if (!window.console) window.console = {};
		if (!console.log) console.log = $.noop;
		if (!console.group) console.group = console.log;
		if (!console.groupCollapsed) console.groupCollapsed = console.log;
		if (!console.groupEnd) console.groupEnd = $.noop;	
	},
	
	initMap: function() {
		var g = google.maps;
		ttc.center = new g.LatLng(43.65818115533737, -79.40809807006838);
		var myOptions = {
			zoom: 13,
			center: ttc.center,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		var map = ttc.map = new g.Map($("#map-canvas")[0], myOptions);
		
		ttc.geocoder = new google.maps.Geocoder();
	},
	
	/** */
	findLocation: function() {
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition(ttc.onFindLocation, null);
		} else {
			console.error("not supported");
		}
	},
	
	/** Sets the map location and zoom, and looks for streetcars */
	onFindLocation: function(position) {
		console.log(position);
		var g = google.maps;
		ttc.map.setCenter(
			new g.LatLng(position.coords.latitude, position.coords.longitude));
		ttc.map.setZoom(15);
	}
};

window.initMap = ttc.initMap;
$(ttc.init);