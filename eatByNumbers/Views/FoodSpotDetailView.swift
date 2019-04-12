//
//  FoodSpotDetailView.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/12/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class FoodSpotDetailView: UIView {
    
    // MARK: - Outlets
    
    
    // MARK: - Properties
    var foodSpot: FoodSpot!
    weak var delegate: FoodSpotDetailViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        tableView.register(UINib(nibName: "FoodSpotTableViewCell", bundle: nil), forCellReuseIdentifier: "FoodSpotTableViewCell")
//        tableView.delegate = self
//        tableView.dataSource = self
        
//        backgroundContentButton.applyArrowDialogAppearanceWithOrientation(arrowOrientation: .down)
    }
    
    // MARK: - Actions
    // call delegate method
    
    func configureWith(_ foodSpot: FoodSpot) {
        self.foodSpot = foodSpot
        // set outlet values here
        
    }
}

protocol FoodSpotDetailViewDelegate: class {
    func detailsRequestedFor(_ foodSpot: FoodSpot)
}
