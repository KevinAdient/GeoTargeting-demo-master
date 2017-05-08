//
//  RegionProtocol.swift
//  GeoTargeting
//
//  Created by Peter M. Gits on 5/7/2017
//  Copyright © 2017 GeekGaps.com. All rights reserved.
//

import CoreLocation


protocol RegionProtocol {
	var coordinate: CLLocation {get}
	var radius: CLLocationDistance {get}
	var identifier: String {get}

	func updateRegion()
}
