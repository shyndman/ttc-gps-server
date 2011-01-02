ttc = {
	/** An array of stop markers currently on the map. */
	stopMarkers: [],
	
	markerColours: ["blue", "lime", "green", "orange", "purple", "red", "greeny_blue"],
	
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
		
		// Toronto center
		ttc.center = new g.LatLng(43.65818115533737, -79.40809807006838);
		
		// Construct map
		var myOptions = {
			zoom: 13,
			center: ttc.center,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		var map = ttc.map = new g.Map($("#map-canvas")[0], myOptions);
		
		// Add event listener for clicks
		g.event.addListener(map, 'click', ttc.onMapClick);
		
		ttc.geocoder = new google.maps.Geocoder();
	},
	
	/** Gets stops around the clicked position, and displays them on the map */
	onMapClick: function(event) {
		ttc.getAndDisplayStops(event.latLng);
	},
	
	/** */
	findLocation: function() {
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition(ttc.onFindLocation, null);
		} else {
			console.error("find location not supported");
		}
	},
	
	/** Sets the map location and zoom, and looks for streetcars */
	onFindLocation: function(position) {
		console.log(position);
		var g = google.maps;
		ttc.map.setCenter(
			new g.LatLng(position.coords.latitude, position.coords.longitude));
		ttc.map.setZoom(15);
	},
	
	/** 
	 * Gets stops associated with the provided route (or all of them, if null),
	 * and places them as markers on the map.
	 */
	getAndDisplayStops: function(latLng) {
		$.getJSON("/closest_stops?lat=" + latLng.lat() + "&lng=" + latLng.lng(), null, ttc.onGetStops);
	},
	
	/** Removes previous markers, then adds the new ones. */
	onGetStops: function(stops) {
		ttc.removeStopMarkers();
		ttc.addStopMarkers(stops);
	},
	
	/** Adds markers for each of the provided stops */
	addStopMarkers: function(stops) {
		var g = google.maps;
		
		var len = stops.length;
		for (var i = 0; i < len; i++) {
			var stop = stops[i];
			var position = stop.position;
			var latlng = new g.LatLng(position.lat, position.lng);
			
			var colour = ttc.markerColours[stop.routeId % ttc.markerColours.length];
			var marker = new g.Marker({icon: "/img/marker_sprite_" + colour + ".png"});
			marker.setMap(ttc.map);
			marker.setPosition(latlng);
			
			ttc.stopMarkers.push(marker);
		}
	},
	
	removeStopMarkers: function() {
		var len = ttc.stopMarkers.length;
		for (var i = 0; i < len; i++) {
			ttc.stopMarkers[i].setMap(null);
		}
		
		ttc.stopMarkers = [];
	}
};

window.initMap = ttc.initMap;
$(ttc.init);