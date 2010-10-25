ttc = {
	init: function() {
		// Initialize the console
		ttc.initConsole();
		
		// Load the Google map
		$.getScript("http://maps.google.com/maps/api/js?v=3.1&sensor=true&callback=initMap");

		// Event handlers
		ttc.addInteractions();	
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
		var map = ttc.map = new g.Map($("#map_canvas")[0], myOptions);
		
		ttc.geocoder = new google.maps.Geocoder();
	},
	
	addInteractions: function() {
		$("#enter-location-form").submit(function() {
			var val = $("#user-location").val();
			if (!ttc.validateUserLocation(val)) {
				return false;
			}
			
			if (val.toLowerCase().indexOf('toronto') == -1) {
				val += ", Toronto";
			}
			
			$("#user-location").attr("disabled","disabled");
			$("#thinking").fadeIn(500);
			$("#enter-location").addClass("disabled");

			ttc.geocoder.geocode({address: val}, ttc.onGeocode);

			return false;
		});	
	},
	
	
	validateUserLocation: function(userInput) {
		return $.trim(userInput).length != 0;
	},
	
	/** Called when we receive Google geocoding information. */
	onGeocode: function(results, status) {
		console.log(results);
		
		if (status != google.maps.GeocoderStatus.OK) {
			alert("Something has gone horribly wrong. That something is this: \"" + status + "\"");
		}
		
		var loc = results[0].geometry.location;
		$.getJSON("/closest_routes/" + loc.lat() + "/" + loc.lng(), ttc.onClosestRoutes);
	},
	
	/** Called when we receive the closest routes from the server */
	onClosestRoutes: function(routes) {
		console.log(routes);
		
		$("#enter-location").fadeOut(400, function() {
			$("#route-list").fadeIn(400);
		});
		
		// setup route list
		$("#route-template").tmpl(routes).appendTo("#route-list > ul");
	}
};

window.initMap = ttc.initMap;
$(ttc.init);