ttc = {
	/** An array of stop markers currently on the map. */
	stopMarkers: [],
	vehicleMarkers: [],
	
	markerColours: ["blue", "lime", "green", "orange", "purple", "red", "greeny_blue"],
	
	init: function() {		
		// Initialize the console
		ttc.initConsole();
		
		// Initialize the map
		ttc.initMap();
		
		// Find location of computer
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
		// Set full screen for phones.
		var userAgent = navigator.userAgent;
		if (userAgent.indexOf('iPhone') != -1 || userAgent.indexOf('Android') != -1 ) {
			$("#map-canvas").width("100%").height("100%");
		}
		
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
//		ttc.getAndDisplayStops(event.latLng);
		ttc.getAndDisplayVehicles(event.latLng);
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
		ttc.getAndDisplayStops({
			lat: function() { return position.coords.latitude; }, 
			lng: function() { return position.coords.longitude; }
		});
/*		console.log(position);
		var g = google.maps;
		ttc.map.setCenter(
			new g.LatLng(position.coords.latitude, position.coords.longitude));
		ttc.map.setZoom(15); */
	},
	
	/** 
	 * Gets stops near the provided location and places them as markers on the map.
	 */
	getAndDisplayStops: function(latLng) {
		$.getJSON("/stops?lat=" + latLng.lat() + "&lng=" + latLng.lng(), null, function(stops) {
			console.log("stops received");
			ttc.removeMarkers(ttc.stopMarkers);
			ttc.addMarkers(stops, ttc.stopMarkers, ttc.onStopClick);
		});
	},
	
	/** Opens an info window describing the stop. */
	onStopClick: function(event, stop, marker) {
		console.log("stop clicked");
		var infowindow = new google.maps.InfoWindow({
		    content: stop.title
		});
	},
	
	/** 
	 * Gets vehicles near the provided location and places them as markers on the map.
	 */
	getAndDisplayVehicles: function(latLng) {
		$.getJSON("/vehicles?lat=" + latLng.lat() + "&lng=" + latLng.lng(), null, function(vehicles) {
			console.log("vehicles received");
			ttc.removeMarkers(ttc.vehicleMarkers);
			ttc.addMarkers(vehicles, ttc.vehicleMarkers);
		});
	},
	
	/* === MARKER MANAGEMENT === */
	
	/** 
	 * Adds markers to the map as specified by the markables array. Each generated
	 * marker is added to the provided markers array.
	 *
	 * If an onClick function is supplied, it will be called when the marker is clicked.
	 * The function should have the following signiture:
	 *
	 *		function(event, markable, marker)
	 */
	addMarkers: function(markables, markers, onClick) {
		var g = google.maps;
		
		var len = markables.length;
		for (var i = 0; i < len; i++) {
			var markable = markables[i];
			var position = markable.position;
			var latlng = new g.LatLng(position.lat, position.lng);
			
			var colour = ttc.markerColours[markable.routeId % ttc.markerColours.length];
			var marker = new g.Marker({icon: "/img/marker_sprite_" + colour + ".png"});
			marker.setMap(ttc.map);
			marker.setPosition(latlng);
			
			if (onClick != null) {
				g.event.addListener(marker, 'click', function(event) {
					onClick(event, markable, marker);
				});
			}
			
			markers.push(marker);
		}
	},
	
	/** Remove all markers in the provided array from the map */
	removeMarkers: function(markers) {
		var len = markers.length;
		for (var i = 0; i < len; i++) {
			markers[i].setMap(null);
		}
		
		markers.splice(0, markers.length); // clear the markers array
	}
};

$(ttc.init);