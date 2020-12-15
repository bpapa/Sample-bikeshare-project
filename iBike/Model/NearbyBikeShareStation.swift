//
//  NearbyBikeShareStation.swift
//  iBike
//
//  Created by Brian Papa on 7/8/20.
//  Copyright © 2020 bpm apps LLC. All rights reserved.
//

import Foundation
import CoreLocation

struct NearbyBikeShareStation {
    let bikeShareStation: BikeShareAPIStation
    let distance: CLLocationDistance
}
