//
//  BikeShareAPIController.swift
//  bikebuddy
//
//  Created by Brian Papa on 5/1/18.
//  Copyright © 2018 bpm apps LLC. All rights reserved.
//

import UIKit
import CoreLocation

enum BikeShareAPIControllerError: Error {
    case noData
}

class BikeShareAPIController : NSObject {
    
    static let sharedInstance: BikeShareAPIController = {
        let instance = BikeShareAPIController()
        return instance
    }()
        
    func getBikeShareStations(userLocation: CLLocation, completionHandler: @escaping (Result<[NearbyBikeShareStation], Error>) -> Void) {
        URLSession.shared.dataTask(with: URL(string: "https://feeds.citibikenyc.com/stations/stations.json")!) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(BikeShareAPIControllerError.noData))
                return
            }
            
            let jsonDecoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "y-MM-dd hh:mm:ss a"
            jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
            do {
                // decode the bike share stations
                let apiBikeShareStations = try jsonDecoder.decode(BikeShareAPIExecution.self, from: data).stationBeanList
                var nearbyBikeShareStations: [NearbyBikeShareStation] = []
                // for each decoded bike share station, create a new "Nearby" instance which contains the station data + the distance from the user. This is adding a bit to memory overhead so would be something to keep an eye on as the app scales.
                apiBikeShareStations.forEach {
                    let nearbyStation = NearbyBikeShareStation(bikeShareStation: $0, distance: userLocation.distance(from: $0.location))
                    nearbyBikeShareStations.append(nearbyStation)
                }
                // sort the nearby stations in place. according to docs this yields O(n log n) complexity
                nearbyBikeShareStations.sort { $0.distance < $1.distance }
                
                completionHandler(.success(nearbyBikeShareStations))
            } catch {
                completionHandler(.failure(error))
            }
        }.resume()
    }
}
