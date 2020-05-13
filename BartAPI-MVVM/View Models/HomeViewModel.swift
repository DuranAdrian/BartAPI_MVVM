//
//  HomeViewModel.swift
//  BartAPI-MVVM
//
//  Created by Adrian Duran on 5/12/20.
//  Copyright © 2020 AdrianDuran. All rights reserved.
//

/*
 Since the HomeViewController will only use the closetStation. This ViewModel will only contain a single Station along with a single North Bound Train (EstimateDeparture) and a single South Bound Train (EstimateDeparture)
 The properties are optional due to being reliant on whether or not the user gave location permissions. However, regardless of permissions it will contain a list of Stations.
 */

import UIKit
import CoreLocation

class HomeViewModel {
    var listOfStations: [Station]
    var closestStation: Station?
    var distanceInMiles: String?
    var nextNorthTrain: EstimateDeparture?
    var nextSouthTrain: EstimateDeparture?
    
    init(stations: [Station]) {
        self.listOfStations = stations
        self.closestStation = nil
        self.distanceInMiles = nil
        self.nextNorthTrain = nil
        self.nextSouthTrain = nil
    }
    
    init() {
        self.listOfStations = []
        self.closestStation = nil
        self.distanceInMiles = nil
        self.nextNorthTrain = nil
        self.nextSouthTrain = nil
    }
    
    /* Because My network API already takes care of finding the directional train departure I left it as it was and called that method in the view controller,
     I wasn't sure if should make the network call here but I did not want to create ANOTHER NetworkManager if the View Controller already has one.
    */
    private static func determineDirectionalTrain() -> EstimateDeparture? {
        return nil
    }
    
    private static func convertMetersToMiles(_ distance: Double?) -> String? {
        if let distance = distance {
            return "\(String(format: "%.2f", ((distance / 1000.0 ) * 0.62137))) Miles"
        }
        return nil
    }
    
    /* After User has given permissions, use this function to set the closest Station and Convert the distance to readable text
     However given that I need the user location, I must pass in the user location determined in the view controller.
     */
    func setClosestStation(with userLocation: CLLocation) {
        var closestStation: Station?
        var smallestDistance: CLLocationDistance?
        
        for station in self.listOfStations {
            let distance = userLocation.distance(from: station.location)
            if smallestDistance == nil || distance < smallestDistance! {
                closestStation = station
                smallestDistance = distance
            }
        }
        self.closestStation = closestStation
        self.distanceInMiles = HomeViewModel.convertMetersToMiles(smallestDistance)
    }
}
