//
//  ViewController.swift
//  GeoTargeting
//
//  Created by Peter M. Gits on 5/7/2017
//  Copyright © 2017 GeekGaps.com. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

	@IBOutlet weak var mapView: MKMapView!

	let locationManager = CLLocationManager()
	var monitoredRegions: Dictionary<String, Date> = [:]

	override func viewDidLoad() {
		super.viewDidLoad()

		// setup locationManager
		locationManager.delegate = self;
		locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;

		// setup mapView
		mapView.delegate = self
		mapView.showsUserLocation = true
		mapView.userTrackingMode = .follow

		// setup test data
		setupData()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// status is not determined
		if CLLocationManager.authorizationStatus() == .notDetermined {
			locationManager.requestAlwaysAuthorization()
		}
		// authorization were denied
		else if CLLocationManager.authorizationStatus() == .denied {
			showAlert("Location services were previously denied. Please enable location services for this app in Settings.")
		}
		// we do have authorization
		else if CLLocationManager.authorizationStatus() == .authorizedAlways {
			locationManager.startUpdatingLocation()
		}
	}

	func setupData() {
		// check if can monitor regions
		if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {

			// region data
			let title = "Dillards's"
			let coordinate = CLLocationCoordinate2DMake(37.703026, -121.759735)
			let regionRadius = 1000.0

			// setup region
			let region = CLCircularRegion(center: coordinate, radius: regionRadius, identifier: title)
			locationManager.startMonitoring(for: region)

			// setup annotation
			let restaurantAnnotation = MKPointAnnotation()
			restaurantAnnotation.coordinate = coordinate;
			restaurantAnnotation.title = "\(title)";
			mapView.addAnnotation(restaurantAnnotation)

			// setup circle
			let circle = MKCircle(center: coordinate, radius: regionRadius)
			mapView.add(circle)
            
            createKissingCircle(theCoordinates:coordinate, distanceInMeters:2000, directionInDegrees:60, title:"kissing60")
            createKissingCircle(theCoordinates:coordinate, distanceInMeters:2000, directionInDegrees:120, title:"kissing120")
            createKissingCircle(theCoordinates:coordinate, distanceInMeters:2000, directionInDegrees:180, title:"kissing180")
            createKissingCircle(theCoordinates:coordinate, distanceInMeters:2000, directionInDegrees:240, title:"kissing240")
            createKissingCircle(theCoordinates:coordinate, distanceInMeters:2000, directionInDegrees:300, title:"kissing300")
            createKissingCircle(theCoordinates:coordinate, distanceInMeters:2000, directionInDegrees:360, title:"kissing360")
        /*
            let kissingCoordinate = getKissingNumber(latitude:coordinate.latitude, longitude: coordinate.longitude, distanceInMeters:2000, directionInDegrees:60)
            let regionKiss = CLCircularRegion(center: CLLocationCoordinate2D(latitude: kissingCoordinate.coordinate.latitude, longitude: kissingCoordinate.coordinate.longitude), radius: regionRadius, identifier: title)
            locationManager.startMonitoring(for: regionKiss)
            
            // setup annotation
            let kissingAnnotation = MKPointAnnotation()
            kissingAnnotation.coordinate = kissingCoordinate.coordinate;
            kissingAnnotation.title = "Kissing60";
            mapView.addAnnotation(kissingAnnotation)
            
            // setup circle
            let kissingCircle = MKCircle(center: kissingCoordinate.coordinate, radius: regionRadius)
            mapView.add(kissingCircle)
    */
            
		}
		else {
			print("System can't track regions")
		}
	}
    
    func createKissingCircle(theCoordinates:CLLocationCoordinate2D, distanceInMeters:Int, directionInDegrees:Int, title:String)->Void
    {
    
        let kissingCoordinate = getKissingNumber(latitude:theCoordinates.latitude, longitude: theCoordinates.longitude, distanceInMeters:distanceInMeters, directionInDegrees:directionInDegrees)
        let regionKiss = CLCircularRegion(center: CLLocationCoordinate2D(latitude: kissingCoordinate.coordinate.latitude, longitude: kissingCoordinate.coordinate.longitude), radius: CLLocationDistance(distanceInMeters/2), identifier: title)
        locationManager.startMonitoring(for: regionKiss)
        
        // setup annotation
        let kissingAnnotation = MKPointAnnotation()
        kissingAnnotation.coordinate = kissingCoordinate.coordinate
        kissingAnnotation.title = title
        mapView.addAnnotation(kissingAnnotation)
        
        // setup circle
        let kissingCircle = MKCircle(center: kissingCoordinate.coordinate, radius: CLLocationDistance(distanceInMeters/2))
        mapView.add(kissingCircle)
    }
    // MARK: - MKMapViewDelegate

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let circleRenderer = MKCircleRenderer(overlay: overlay)
		circleRenderer.strokeColor = UIColor.red
		circleRenderer.lineWidth = 1.0
		return circleRenderer
	}

	// MARK: - CLLocationManagerDelegate

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		showAlert("enter \(region.identifier)")
		monitoredRegions[region.identifier] = Date()
	}

	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		showAlert("exit \(region.identifier)")
		monitoredRegions.removeValue(forKey: region.identifier)
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		updateRegionsWithLocation(locations[0])
	}

	// MARK: - Comples business logic

	func updateRegionsWithLocation(_ location: CLLocation) {

		let regionMaxVisiting = 10.0
		var regionsToDelete: [String] = []

		for regionIdentifier in monitoredRegions.keys {
			if Date().timeIntervalSince(monitoredRegions[regionIdentifier]!) > regionMaxVisiting {
				showAlert("Thanks for visiting")

				regionsToDelete.append(regionIdentifier)
			}
		}

		for regionIdentifier in regionsToDelete {
			monitoredRegions.removeValue(forKey: regionIdentifier)
		}
	}

	// MARK: - Helpers

	func showAlert(_ title: String) {
		let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
		}))
		self.present(alert, animated: true, completion: nil)

	}

    func getKissingNumber(latitude:Double, longitude:Double, distanceInMeters:Int, directionInDegrees:Int) -> CLLocation {
        
 //       let location = CLLocation(latitude: 41.88592 as CLLocationDegrees, longitude: -87.62788 as CLLocationDegrees)
        let location = CLLocation(latitude: latitude, longitude: longitude)

        //let distanceInMeters : Int = 500
        //let directionInDegrees : Int = 135

        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude

        let radDirection : CGFloat = Double(directionInDegrees).degreesToRadians

        let dx = Double(distanceInMeters) * cos(Double(radDirection))
        let dy = Double(distanceInMeters) * sin(Double(radDirection))

        let radLat : CGFloat = Double(lat).degreesToRadians

        let deltaLongitude = dx/(111320 * Double(cos(radLat)))
        let deltaLatitude = dy/110540

        let endLat = lat + deltaLatitude
        let endLong = long + deltaLongitude
        let newPointLocation = CLLocation(latitude: endLat as CLLocationDegrees, longitude: endLong as CLLocationDegrees)
        return newPointLocation
    }
}

extension Double {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat.pi / 180.0
    }
}

/*
func Point_At_Distance_And_Bearing(start_lat:double,start_lon:double,distance_text:double,bearing:double) ->CLLocation { // input is in degrees, km, degrees
    // http://www.fcc.gov/mb/audio/bickel/sprong.html
    var ending_point = [] // output
    var earth_radius = 6378137; // equatorial radius
    // var earth_radius = 6356752; // polar radius
    // var earth_radius = 6371000; // typical radius
    var start_lat_rad = start_lat//deg2rad(parseCoordinate(start_lat));
    var start_lon_rad = start_long//deg2rad(parseCoordinate(start_lon));
    var distance = distance_text//parseDistance(distance_text);
    
    bearing = parseBearing(bearing);
    if (Math.abs(bearing) >= 360) { bearing = bearing % 360; }
    bearing = (bearing < 0) ? bearing+360 : bearing;
    var isig = (bearing <= 180) ? 1 : 0; // western half of circle = 0, eastern half = 1
    var a = 360-bearing; // this subroutine measures angles COUNTER-clockwise, so +3 becomes +357
    a = deg2rad(a); var bb = (Math.PI/2)-start_lat_rad; var cc = distance/earth_radius;
    var sin_bb = Math.sin(bb); var cos_bb = Math.cos(bb); var cos_cc = Math.cos(cc);
    var cos_aa = cos_bb*cos_cc+(sin_bb*Math.sin(cc)*Math.cos(a));
    if (cos_aa <= -1) { cos_aa = -1; } if (cos_aa >= 1) { cos_aa = 1; }
    var aa = (cos_aa.toFixed(15) == 1) ? 0 : Math.acos(cos_aa);
    var cos_c = (cos_cc-(cos_aa*cos_bb))/(Math.sin(aa)*sin_bb);
    if (cos_c <= -1) { cos_c = -1; } if (cos_c >= 1) { cos_c = 1; }
    var c = (cos_c.toFixed(15) == 1) ? 0 : Math.acos(cos_c);
    var end_lat_rad = (Math.PI/2)-aa;
    var end_lon_rad = start_lon_rad-c;
    if (isig == 1) { end_lon_rad = start_lon_rad + c; }
    if (end_lon_rad > Math.PI) { end_lon_rad = end_lon_rad - (2*Math.PI); }
    if (end_lon_rad < (0-Math.PI)) { end_lon_rad = end_lon_rad + (2*Math.PI); }
    ending_point[0] = rad2deg(end_lat_rad); ending_point[1] = rad2deg(end_lon_rad);
    // Use proportional error to adjust things due to oblate Earth; I'm still not entirely sure how/why this works:
    for (i=0; i<5; i++) {
        var vincenty = Vincenty_Distance(start_lat,start_lon,ending_point[0],ending_point[1],false,true);
        if (Math.abs(start_lon-ending_point[1]) > 180) {
            // something went haywire
        } else {
            var error = (vincenty != 0) ? distance/vincenty : 1;
            var dlat = ending_point[0]-parseFloat(start_lat); var dlon = ending_point[1]-parseFloat(start_lon);
            ending_point[0] = parseFloat(start_lat)+(dlat*error); ending_point[1] = parseFloat(start_lon)+(dlon*error);
        }
    }
    return (ending_point);
}

func parseBearing(bearing_text) { // returns degrees
    var degrees;
    if (bearing_text.toUpperCase().match(/[NS].*[0-9].*[EW]/i)) {
        parts = bearing_text.toUpperCase().match(/([NS])(.*[0-9].*)([EW])/);
        degrees = parts[2];
        if (parts[1] == 'N' && parts[3] == 'E') { degrees = 0 + parseFloat(parseCoordinate(degrees)); }
        else if (parts[1] == 'N' && parts[3] == 'W') { degrees = 360 - parseFloat(parseCoordinate(degrees)); }
        else if (parts[1] == 'S' && parts[3] == 'E') { degrees = 180 - parseFloat(parseCoordinate(degrees)); }
        else if (parts[1] == 'S' && parts[3] == 'W') { degrees = 180 + parseFloat(parseCoordinate(degrees)); }
    } else {
        degrees = parseFloat(parseCoordinate(bearing_text.replace(/[NSEW]/gi,' ')));
    }
    return degrees;
}

func deg2rad (deg) {
    return (parseFloat(comma2point(deg)) * 3.14159265358979/180);
}

func comma2point (number) {
    number = number+''; // force number into a string context
    return (number.replace(/,/g,'.'));
}
function Vincenty_Distance(lat1,lon1,lat2,lon2,us,meters_only) {
    // http://www.movable-type.co.uk/scripts/LatLongVincenty.html
    if (Math.abs(parseFloat(lat1)) > 90 || Math.abs(parseFloat(lon1)) > 180 || Math.abs(parseFloat(lat2)) > 90 || Math.abs(parseFloat(lon2)) > 180) { return 'n/a'; }
    if (lat1 == lat2 && lon1 == lon2) { return '0'; }
    
    lat1 = deg2rad(lat1); lon1 = deg2rad(lon1);
    lat2 = deg2rad(lat2); lon2 = deg2rad(lon2);
    
    var a = 6378137, b = 6356752.3142, f = 1/298.257223563;
    var L = lon2 - lon1;
    var U1 = Math.atan((1-f) * Math.tan(lat1));
    var U2 = Math.atan((1-f) * Math.tan(lat2));
    var sinU1 = Math.sin(U1), cosU1 = Math.cos(U1);
    var sinU2 = Math.sin(U2), cosU2 = Math.cos(U2);
    var lambda = L, lambdaP = 2*Math.PI;
    var iterLimit = 50;
    while (Math.abs(lambda-lambdaP) > 1e-12 && --iterLimit > 0) {
        var sinLambda = Math.sin(lambda), cosLambda = Math.cos(lambda);
        var sinSigma = Math.sqrt((cosU2*sinLambda) * (cosU2*sinLambda) +
            (cosU1*sinU2-sinU1*cosU2*cosLambda) * (cosU1*sinU2-sinU1*cosU2*cosLambda));
        var cosSigma = sinU1*sinU2 + cosU1*cosU2*cosLambda;
        var sigma = Math.atan2(sinSigma, cosSigma);
        var alpha = Math.asin(cosU1 * cosU2 * sinLambda / sinSigma);
        var cosSqAlpha = Math.cos(alpha) * Math.cos(alpha);
        var cos2SigmaM = (!cosSqAlpha) ? 0 : cosSigma - 2*sinU1*sinU2/cosSqAlpha;
        var C = f/16*cosSqAlpha*(4+f*(4-3*cosSqAlpha));
        lambdaP = lambda;
        lambda = L + (1-C) * f * Math.sin(alpha) * (sigma + C*sinSigma*(cos2SigmaM+C*cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)));
    }
    if (iterLimit==0) { return (NaN); }  // formula failed to converge
    var uSq = cosSqAlpha*(a*a-b*b)/(b*b);
    var A = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
    var B = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
    var deltaSigma = B*sinSigma*(cos2SigmaM+B/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM) - B/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)));
    var s = b*A*(sigma-deltaSigma);
    if (meters_only) {
        return s;
    } else if (us==2) {
        var dist = s / 1852;
        if (dist < 0.2) {
            return (Math.round(6076.1155 * dist) / 1) + ' ft';
        } else {
            return (Math.round(1000 * dist) / 1000) + ' NM';
        }
    } else if (us) {
        var dist = s / 1609.344;
        if (dist < 0.2) {
            return (Math.round(5280 * dist) / 1) + ' ft';
        } else {
            return (Math.round(1000 * dist) / 1000) + ' mi';
        }
    } else {
        var dist = s / 1000;
        if (dist < 1) {
            return (Math.round(1000 * dist) / 1) + ' m';
        } else {
            return (Math.round(1000 * dist) / 1000) + ' km';
        }
    }
}



func deg2rad (deg) {
    return (parseFloat(comma2point(deg)) * 3.14159265358979/180);
}

func parseCoordinate(coordinate,type,format,spaced) {
    coordinate = coordinate.toString();
    coordinate = coordinate.replace(/(^\s+|\s+$)/g,''); // remove white space
    var neg = 0; if (coordinate.match(/(^-|[WS])/i)) { neg = 1; }
    if (coordinate.match(/[EW]/i) && !type) { type = 'lon'; }
    if (coordinate.match(/[NS]/i) && !type) { type = 'lat'; }
    coordinate = coordinate.replace(/[NESW\-]/gi,' ');
    if (!coordinate.match(/[0-9]/i)) {
        return '';
    }
    parts = coordinate.match(/([0-9\.\-]+)[^0-9\.]*([0-9\.]+)?[^0-9\.]*([0-9\.]+)?/);
    if (!parts || parts[1] == null) {
        return '';
    } else {
        n = parseFloat(parts[1]);
        if (parts[2]) { n = n + parseFloat(parts[2])/60; }
        if (parts[3]) { n = n + parseFloat(parts[3])/3600; }
        if (neg && n >= 0) { n = 0 - n; }
        if (format == 'dmm') {
            if (spaced) {
                n = Degrees_to_DMM(n,type,' ');
            } else {
                n = Degrees_to_DMM(n,type);
            }
        } else if (format == 'dms') {
            if (spaced) {
                n = Degrees_to_DMS(n,type,' ');
            } else {
                n = Degrees_to_DMS(n,type,'');
            }
        } else {
            n = Math.round(100000000000 * n) / 100000000000;
            if (n == Math.floor(n)) { n = n + '.0'; }
        }
        return comma2point(n);
    }
}
 */
