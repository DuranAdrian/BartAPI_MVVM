//
//  HomeView.swift
//  BartAPI-MVVM
//
//  Created by Adrian Duran on 5/11/20.
//  Copyright © 2020 AdrianDuran. All rights reserved.
//

import UIKit

class HomeView: UIView {
    // Neo Map
    lazy var neoMap: NeoMap! = {
        return NeoMap()
    }()
    
    // Nearest Station Neo Table View
    lazy var stationTableView: NeoTableView! = {
        let table = NeoTableView()
        table.isUserInteractionEnabled = false
        return table
    }()
    
    lazy var nextTrainLabel: UILabel! = {
        let trainLabel = UILabel()
        trainLabel.text = "Next Arriving Train"
        trainLabel.numberOfLines = 1
        trainLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 16.0)
        trainLabel.translatesAutoresizingMaskIntoConstraints = false
        return trainLabel
    }()
    
    // Next Arriving Trains Neo Table View
    lazy var nextTrainsTableView: NeoTableView! = {
       let table = NeoTableView()
       table.isUserInteractionEnabled = false
       return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
    
    private func setUpView() {
        backgroundColor = UIColor.Custom.smokeWhite
        setUpMap()
        setUpTableViews()
    }
    
    private func setUpMap() {
        neoMap = NeoMap(frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0))
        addSubview(neoMap)
        neoMap.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            neoMap.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15),
            neoMap.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            neoMap.heightAnchor.constraint(equalToConstant: 300.0),
            neoMap.widthAnchor.constraint(equalToConstant: 300.0)
        ])
    }
    
    private func setUpTableViews() {
        // Insert Station Table
        addSubview(stationTableView)
        stationTableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Insert Train Label
        addSubview(nextTrainLabel)
        
        // Insert Trains Table
        addSubview(nextTrainsTableView)
        nextTrainsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stationTableView.topAnchor.constraint(equalTo: neoMap.bottomAnchor, constant: 50),
            stationTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            stationTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            
            nextTrainLabel.topAnchor.constraint(equalTo: stationTableView.bottomAnchor, constant: 20),
            nextTrainLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            nextTrainLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),

            nextTrainsTableView.topAnchor.constraint(equalTo: nextTrainLabel.bottomAnchor, constant: 10),
            nextTrainsTableView.trailingAnchor.constraint(equalTo: stationTableView.trailingAnchor),
            nextTrainsTableView.leadingAnchor.constraint(equalTo: stationTableView.leadingAnchor),
            nextTrainLabel.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor)
        ])

    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
