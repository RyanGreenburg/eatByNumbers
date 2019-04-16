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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var directionsButton: UIButton!
    
    
    // MARK: - Properties
    var foodSpot: FoodSpot!
    weak var delegate: FoodSpotDetailViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Actions
    // call delegate method
    @IBAction func directionsButtonTapped(_ sender: Any) {
        delegate?.directionsRequestedFor(foodSpot)
    }
    
    
    func configureWith(_ foodSpot: FoodSpot) {
        self.foodSpot = foodSpot
        // set outlet values here
        nameLabel.text = foodSpot.name
        nameLabel.textColor = Colors.white.color()
        addressLabel.text = foodSpot.address
        addressLabel.textColor = Colors.white.color()
        scoreLabel.text = "\(foodSpot.usersFavoriteReferences.count)"
        scoreLabel.textColor = Colors.white.color()
        directionsButton.setTitleColor(Colors.lightBlue.color(), for: .normal)
    }
    
    // MARK: - Hit test. We need to override this to detect hits in our custom callout.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if let result = directionsButton.hitTest(convert(point, to: directionsButton), with: event) {
            delegate?.directionsRequestedFor(foodSpot)
            return result
        }
        return nil
    }
}

protocol FoodSpotDetailViewDelegate: class {
    func directionsRequestedFor(_ foodSpot: FoodSpot)
}
