//
//  StationDetailTableViewController.swift
//  iBike
//
//  Created by Brian Papa on 7/6/20.
//  Copyright © 2020 bpm apps LLC. All rights reserved.
//

import UIKit

class StationDetailTableViewController: UITableViewController {

    // MARK: - outlets
    @IBOutlet weak var availableBikesLabel: UILabel!
    @IBOutlet weak var availableDocksLabel: UILabel!
    @IBOutlet weak var totalDocksLabel: UILabel!
    @IBOutlet weak var executionTimeLabel: UILabel!
    
    // MARK: - instance properties
    var station: BikeShareAPIStation?
    
    // MARK: - UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let station = station else { return }
        title = station.stationName
        availableBikesLabel.text = "\(station.availableBikes)"
        availableDocksLabel.text = "\(station.availableDocks)"
        totalDocksLabel.text = "\(station.totalDocks)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .long
        executionTimeLabel.text =  dateFormatter.string(from: station.lastCommunicationTime)
    }
}
