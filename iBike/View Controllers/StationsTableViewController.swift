//
//  StationsTableViewController.swift
//  iBike
//
//  Created by Brian Papa on 7/6/20.
//  Copyright © 2020 bpm apps LLC. All rights reserved.
//

import UIKit
import MapKit

class StationsTableViewController: UITableViewController {

    // MARK: - properties
    var stations: [NearbyBikeShareStation]? {
        didSet {
            tableView.reloadData()
        }
    }
    lazy var distanceFormatter = MKDistanceFormatter()
     
    // MARK: - UIViewController methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let stations = stations, let selectedIndexPath = tableView.indexPathForSelectedRow, let stationTableViewController = segue.destination as? StationDetailTableViewController else { return }
        stationTableViewController.station = stations[selectedIndexPath.row].bikeShareStation
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let stations = stations else {
            fatalError("Stations must not be nil to create table view cell")
        }
        
        let nearbyStation = stations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = nearbyStation.bikeShareStation.stationName
        cell.detailTextLabel?.text = distanceFormatter.string(fromDistance: nearbyStation.distance)

        return cell
    }

}
