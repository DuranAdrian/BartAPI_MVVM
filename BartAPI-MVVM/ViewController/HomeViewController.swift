//
//  ViewController.swift
//  BartAPI-MVVM
//
//  Created by Adrian Duran on 5/11/20.
//  Copyright © 2020 AdrianDuran. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    lazy var  neoHomeView: HomeView! = {
        return HomeView()
    }()

    lazy var networkManager: NetworkManager! = NetworkManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        neoHomeView = HomeView(frame: view.frame)
        neoHomeView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(neoHomeView)
        NSLayoutConstraint.activate([
            neoHomeView.topAnchor.constraint(equalTo: view.topAnchor),
            neoHomeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            neoHomeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            neoHomeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        neoHomeView.stationTableView.tableView.delegate = self
        neoHomeView.stationTableView.tableView.dataSource = self
        neoHomeView.stationTableView.tableView.register(NearestStationCell.self, forCellReuseIdentifier: "NearestStationCell")
        neoHomeView.stationTableView.tableView.rowHeight = UITableView.automaticDimension
        neoHomeView.stationTableView.tableView.estimatedRowHeight = 45.0
        
        neoHomeView.nextTrainsTableView.tableView.delegate = self
        neoHomeView.nextTrainsTableView.tableView.dataSource = self
        neoHomeView.nextTrainsTableView.tableView.register(NextTrainCell.self, forCellReuseIdentifier: "NextTrainCell")
        neoHomeView.nextTrainsTableView.tableView.rowHeight = UITableView.automaticDimension
        neoHomeView.nextTrainsTableView.tableView.estimatedRowHeight = 45.0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        neoHomeView.stationTableView.invalidateIntrinsicContentSize()
        neoHomeView.nextTrainsTableView.invalidateIntrinsicContentSize()
    }
}


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
            let cell = tableView.dequeueReusableCell(withIdentifier: "NearestStationCell", for: indexPath) as! NearestStationCell
            cell.stationName.text = "San Leandro"
            cell.stationDistance.text = "1.22 Miles"
            return cell
        }
        if tableView == neoHomeView.nextTrainsTableView.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NextTrainCell", for: indexPath) as! NextTrainCell
            cell.routeDirection.text = "North"
            cell.routeColorView.backgroundColor = UIColor.BARTCOLORS.BLUE.colors
            cell.destination.text = "Daly City"
            cell.estimatedTimeArrival.text = "9 Mins"
            return cell
        }
        
        return UITableViewCell()
    }
    
    
}

