//
//  VenueDetailView.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/15/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class VenueDetailView: UIView {

    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var directionsButton: UIButton!
    
    
    // MARK: - Properties
    var venue: Venue!
    weak var delegate: VenueDetailViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Actions
    // call delegate method
    @IBAction func directionsButtonTapped(_ sender: Any) {
        delegate?.directionsRequestedFor(venue)
    }
    
    
    func configureWith(_ venue: Venue) {
        self.venue = venue
        // set outlet values here
        nameLabel.text = venue.name
        addressLabel.text = venue.location.address
        scoreLabel.text = ""
    }
    
    // MARK: - Hit test. We need to override this to detect hits in our custom callout.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if let result = directionsButton.hitTest(convert(point, to: directionsButton), with: event) {
            return result
        }
        return nil
    }
}

protocol VenueDetailViewDelegate: class {
    func directionsRequestedFor(_ venue: Venue)
}
