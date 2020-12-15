//
//  ViewController.swift
//  iBike
//
//  Created by Brian Papa on 7/6/20.
//  Copyright © 2020 bpm apps LLC. All rights reserved.
//

import UIKit
import CoreLocation

enum ContainerViewControllerState {
    case notLocated, requestingAuthorization, locating, downloading, error(Error), viewingStations([NearbyBikeShareStation])
}

class ContainerViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet var locateButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var messageLabel: UILabel!
    
    // MARK: Properties
    fileprivate var containerViewControllerState = ContainerViewControllerState.notLocated {
        didSet {
            DispatchQueue.main.async {
                self.configureView(for: self.containerViewControllerState)
            }
        }
    }
    lazy private var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    var stationsTableViewController: StationsTableViewController? {
        return children.first as? StationsTableViewController
    }
    
    // MARK: Action methods
    @IBAction func locate(_ sender: Any) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            requestLocation()
        } else {
            containerViewControllerState = .requestingAuthorization
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: Private methods
    /// Configures the subviews of `view`. Initially, a button prompting to search for location is displayed. An activity indicator and label are displayed while loading, and an error or content is displayed on load.
    /// - Parameter state:
    private func configureView(for state: ContainerViewControllerState) {
        // a sensible set of defaults that will be overidden by state
        var hidesButton = false
        var activityIndicatorAnimating = false
        var message: String?
        var nearbyBikeShareStations: [NearbyBikeShareStation]?
        
        switch state {
        case .requestingAuthorization:
            hidesButton = true
            activityIndicatorAnimating = true
            message = "Requesting Authorization"
            
        case .locating:
            hidesButton = true
            activityIndicatorAnimating = true
            message = "Locating..."
            
        case .downloading:
            hidesButton = true
            activityIndicatorAnimating = true
            message = "Getting Bike Share data..."
            
        case .error(let error):
            message = error.localizedDescription
            
        case .viewingStations(let stations):
            hidesButton = true
            nearbyBikeShareStations = stations
            
        default:
            break
        }
        
        // update the UI based on defaults + state
        locateButton.isHidden = hidesButton
        
        configureActivityIndicator(animating: activityIndicatorAnimating)
        configureMessageLabel(message: message)
        configureBikeShareStationsTableViewController(stations: nearbyBikeShareStations)
    }
    
    /// Adds the activity indicator to the view hiearchy if needed, and start/end its animation
    /// - Parameter animating: starts or stops the animation
    private func configureActivityIndicator(animating: Bool) {
        if activityIndicator.superview == nil {
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(activityIndicator)
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
        
        animating ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    /// Adds the message label to the view hiearchy if needed and displays a message
    /// - Parameter message: a message to display
    private func configureMessageLabel(message: String?) {
        guard let message = message else {
            messageLabel.removeFromSuperview()
            return
        }
        
        if messageLabel.superview == nil {
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(messageLabel)
            messageLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor).isActive = true
            messageLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            messageLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        }
        
        messageLabel.text = message
    }
    
    /// Adds the stations table view as a child VC if needed and sets its backing array
    /// - Parameter stations: the backing array for the table view controller
    private func configureBikeShareStationsTableViewController(stations: [NearbyBikeShareStation]?) {
        guard let stations = stations else {
            stationsTableViewController?.willMove(toParent: nil)
            stationsTableViewController?.view.removeFromSuperview()
            stationsTableViewController?.removeFromParent()
            return
        }
        
        if let stationsTableViewController = stationsTableViewController {
            stationsTableViewController.stations = stations
        } else if let stationsTableViewContoller = storyboard?.instantiateViewController(identifier: "stationsTableViewController") as? StationsTableViewController {
            addChild(stationsTableViewContoller)
            view.insertSubview(stationsTableViewContoller.view, at: 0)
            stationsTableViewContoller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            stationsTableViewContoller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            stationsTableViewContoller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            stationsTableViewContoller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            stationsTableViewContoller.didMove(toParent: self)
            stationsTableViewContoller.stations = stations
        }
    }
    
    /// Sets the state to `locating` and begins a location request from the `CLLocationManager`
    fileprivate func requestLocation() {
        containerViewControllerState = .locating
        locationManager.requestLocation()
    }
}

// MARK: CLLocationManagerDelegate extension
extension ContainerViewController: CLLocationManagerDelegate {
    enum ContainerViewControllerLocationError: Error, LocalizedError {
        case denied
        var errorDescription: String? { "Turn on Location in Settings" }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // The auth status can change either after user action or when returning from settings - in the case of the latter, don't want to request location until the user taps the button again
        switch containerViewControllerState {
        case .error(_):
            containerViewControllerState = .notLocated
            return
            
        case .requestingAuthorization:
            changeState(for: status)
             
        default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        containerViewControllerState = .downloading
        
        // per the documentation this always contains a first element, so just force unwrapping - a more robust implementation would likely need to handle multiple locations anyway, while the usage here is just a one-time location request
        let location = locations.first!
        BikeShareAPIController.sharedInstance.getBikeShareStations(userLocation: location) { (result) in
            switch result {
            case .success(let stations):
                self.containerViewControllerState = .viewingStations(stations)
                
            case .failure(let error):
                self.containerViewControllerState = .error(error)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        containerViewControllerState = .error(error)
    }
    
    private func changeState(for status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            requestLocation()
            
        case .denied:
            containerViewControllerState = .error(ContainerViewControllerLocationError.denied)
            
        default:
            break
        }
    }
}

