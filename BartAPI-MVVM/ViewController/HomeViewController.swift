//
//  ViewController.swift
//  BartAPI-MVVM
//
//  Created by Adrian Duran on 5/11/20.
//  Copyright © 2020 AdrianDuran. All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    
    lazy var neoHomeView: HomeView! = {
        return HomeView()
    }()
    
    lazy var stationViewModel: HomeViewModel! = {
        return HomeViewModel()
    }()
    
    lazy var networkManager: NetworkManager! = NetworkManager()
    
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Up newHomeView
        setUpHomeView()
        // setUpStationViewModel()
        locationManager.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // In order to get the tablesview to adjust their height, invalidate the IntrinsicContentSize to recalculate it
        neoHomeView.stationTableView.invalidateIntrinsicContentSize()
        neoHomeView.nextTrainsTableView.invalidateIntrinsicContentSize()
    }
    
    private func setUpHomeView() {
        neoHomeView = HomeView(frame: view.frame)
        neoHomeView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(neoHomeView)
        NSLayoutConstraint.activate([
            neoHomeView.topAnchor.constraint(equalTo: view.topAnchor),
            neoHomeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            neoHomeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            neoHomeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Set Up Tables Views
        neoHomeView.stationTableView.tableView.delegate = self
        neoHomeView.stationTableView.tableView.dataSource = self
        neoHomeView.stationTableView.tableView.register(NearestStationCell.self, forCellReuseIdentifier: "NearestStationCell")
        neoHomeView.stationTableView.tableView.rowHeight = UITableView.automaticDimension
        neoHomeView.stationTableView.tableView.estimatedRowHeight = 1.0
        
        neoHomeView.nextTrainsTableView.tableView.delegate = self
        neoHomeView.nextTrainsTableView.tableView.dataSource = self
        neoHomeView.nextTrainsTableView.tableView.register(NextTrainCell.self, forCellReuseIdentifier: "NextTrainCell")
        neoHomeView.nextTrainsTableView.tableView.rowHeight = UITableView.automaticDimension
        neoHomeView.nextTrainsTableView.tableView.estimatedRowHeight = 1.0
        
        // By Default Hide Tables and Label until permissions are checked
        neoHomeView.nextTrainLabel.isHidden = true
        neoHomeView.stationTableView.isHidden = true
        neoHomeView.nextTrainsTableView.isHidden = true
    }
    
    private func updateHomeView() {
        // Determine whether or not there exist a closest Station from StationViewModel, adjust View from top down
        print("Updating Homeview")
        if let closestStation = stationViewModel.closestStation {
            print("Adding closest Station to map")
            neoHomeView.neoMap.setUpNearest(nearestStation: closestStation)
//            self.neoHomeView.stationTableView.tableView.reloadData()
            neoHomeView.stationTableView.isHidden = false
            print("RELOADING STATIONTABLEVIEW")
            neoHomeView.stationTableView.tableView.reloadData()
            neoHomeView.stationTableView.invalidateIntrinsicContentSize()

            // Since the network can be down in getting the next train, confirm train data is there
            if let nextNorthTrain = stationViewModel.nextNorthTrain, let nextSouthTrain = stationViewModel.nextSouthTrain {
                print("NextNorthTrain or NextSouthTrain is true")
                neoHomeView.nextTrainLabel.isHidden = false
                neoHomeView.nextTrainsTableView.isHidden = false
                neoHomeView.nextTrainsTableView.tableView.reloadSections([0], with: .fade)
                neoHomeView.nextTrainsTableView.invalidateIntrinsicContentSize()
            }
            
        } else {
            // Hide all of UI Except for Map and show restrictive Map Mode, from top down
            print("Hiding Tables")
            neoHomeView.neoMap.setUpRestrictiveMap(listOfStations: stationViewModel.listOfStations)
            neoHomeView.stationTableView.isHidden = true
            neoHomeView.nextTrainLabel.isHidden = true
            neoHomeView.nextTrainsTableView.isHidden = true
        }
    }
    
}

// MARK: - TableView Methods
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == neoHomeView.nextTrainsTableView.tableView {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == neoHomeView.stationTableView.tableView {
            
            // Confirm ClosestStation data is there.
            if let closestStation = stationViewModel.closestStation {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NearestStationCell", for: indexPath) as! NearestStationCell
                cell.stationName.text = closestStation.name
                cell.stationDistance.text = stationViewModel.distanceInMiles
                return cell
            } else {
                return UITableViewCell()
            }
        }
        if tableView == neoHomeView.nextTrainsTableView.tableView {
            if indexPath.row == 0 {
                // As we are dealing with multiple threads, Ensure that there is a next North Train
                if let nextNorthTrain = stationViewModel.nextNorthTrain {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NextTrainCell", for: indexPath) as! NextTrainCell

                    cell.routeDirection.text = "North"
                    cell.routeColorView.backgroundColor = UIColor.BARTCOLORS(rawValue: nextNorthTrain.nextEstimate[0].color)?.colors
                    cell.destination.text = nextNorthTrain.destination
                    cell.estimatedTimeArrival.text = nextNorthTrain.nextEstimate[0].computeTrainETA()
                    cell.arrivingInLabel.attributedText = cell.setArrivalTitle(train: nextNorthTrain.nextEstimate[0])
                    return cell
                }
//                return UITableViewCell()
            } else {
                // As we are dealing with multiple threads, Ensure that there is a next South Train
                if let nextSouthTrain = stationViewModel.nextSouthTrain {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NextTrainCell", for: indexPath) as! NextTrainCell
                    cell.routeDirection.text = "South"
                    cell.routeColorView.backgroundColor = UIColor.BARTCOLORS(rawValue: nextSouthTrain.nextEstimate[0].color)?.colors
                    cell.destination.text = nextSouthTrain.destination
                    cell.estimatedTimeArrival.text = nextSouthTrain.nextEstimate[0].computeTrainETA()
                    cell.arrivingInLabel.attributedText = cell.setArrivalTitle(train: nextSouthTrain.nextEstimate[0])
                    return cell
                }

            }
        }
        let cell = UITableViewCell()
        cell.isHidden = true
        cell.backgroundColor = UIColor.Custom.smokeWhite
        return cell
    }
    
}

// MARK: - Permission Methods

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationPermissions()
    }
    
    private func checkLocationPermissions() {
        print("Checking location Permissions")
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            // Do Network Call to get All Stations
            print("Authorized")
            DispatchQueue.global(qos: .userInitiated).async {
                // Use dispatchGroup to wait until networks calls are complete before updating View
                // This will avoid calling Update View multiple times.
                let group = DispatchGroup()
                group.enter()
                self.networkManager.stations.getStationList(completion: { stations, error in
                    if let error = error {
                        print("Error Fetching StationList: \(error)")
                        group.leave()
                    }
                    if let stations = stations {
                        print("Successful Station List Data Pull")
                        // Set StationViewModel with list of Stations
                        self.stationViewModel = HomeViewModel(stations: stations)
                        
                        // Adjust MapView to Show All Stations
                        // Although we're waiting for all network calls to finish, we will update the map with a list of all stations
                        DispatchQueue.main.async {
                            self.neoHomeView.neoMap.setUpRestrictiveMap(listOfStations: self.stationViewModel.listOfStations)
                        }
                        
                        // Determine Closest Station To User
                        
                        // Confirm User Location
                        guard let userLocation = CLLocationManager().location else {
                            print("Cannot find user location")
                            group.leave()
                            return
                        }
                        // Set Closest Station and distance
                        self.stationViewModel.setClosestStation(with: userLocation)

                        // Determine Next Directional Trains
                        if let _ = self.stationViewModel.closestStation {
                            group.enter()
                            self.networkManager.eta.getFirstNorthTrain(to: self.stationViewModel.closestStation!.abbreviation, completion: {
                                estimate, error in
                                if let error = error {
                                    print("Error getting first North train: \(error)")
                                    group.leave()
                                }
                                if let estimate = estimate {
                                    print("SUCCESSFULL NEXT NORTH ESTIMATE")
                                    self.stationViewModel.nextNorthTrain = estimate
                                    group.leave()
                                }
                            })
                            group.enter()
                            self.networkManager.eta.getFirstSouthTrain(to: self.stationViewModel.closestStation!.abbreviation, completion: {
                                estimate, error in
                                if let error = error {
                                    print("Error getting first South train: \(error)")
                                    group.leave()
                                }
                                if let estimate = estimate {
                                    print("SUCCESSFULL NEXT SOUTH ESTIMATE")
                                    self.stationViewModel.nextSouthTrain = estimate
                                    group.leave()
                                }
                            })
                        }
                        
                        // Leave Main Group
                        group.leave()
                    }
                })
                group.notify(queue: .main) { [weak self] in
                    print("COMPLETED NETWORK CALLS")
                    self?.updateHomeView()
                }
                
            }
        case .denied:
            print("Denied")
            break
        case .notDetermined:
            print("Not Determined")
            locationManager.requestWhenInUseAuthorization()
            updateHomeView()
            break
        case .restricted:
            print("Restricted")
            break
        @unknown default:
            print("Unknown Permissions")
            locationManager.requestWhenInUseAuthorization()
            updateHomeView()
            break
        }
    }
}

