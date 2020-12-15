//
//  BikeShareExecution.swift
//  bikebuddy
//
//  Created by Brian Papa on 4/26/18.
//  Copyright © 2018 bpm apps LLC. All rights reserved.
//

import Foundation
import CoreLocation

struct BikeShareAPIExecution : Codable {
    let executionTime: Date
    let stationBeanList : [BikeShareAPIStation]
}

struct BikeShareAPIStation : Codable {
    let id : Int
    let stationName : String
    let availableDocks : Int
    let totalDocks : Int
    let availableBikes : Int
    let latitude : CLLocationDegrees
    let longitude : CLLocationDegrees
    let statusValue : String
    let lastCommunicationTime : Date
        
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
