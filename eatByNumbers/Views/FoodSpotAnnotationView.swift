//
//  FoodSpotAnnotationView.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import MapKit

class FoodSpotAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
        self.centerOffset = CGPoint(x: 0, y: -5)
        let image = UIImage(named: "foodSpotIcon")
        let resizedImage = image?.resizeImage(targetSize: CGSize(width: 50, height: 50))
        self.image = resizedImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false
        self.centerOffset = CGPoint(x: 0, y: -5)
        let image = UIImage(named: "foodSpotIcon")
        let resizedImage = image?.resizeImage(targetSize: CGSize(width: 50, height: 50))
        self.image = resizedImage
    }
    
    // MARK: - show/hide callout
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        

    }
    
    func animateDrop() {
        self.frame.origin.y = -1000
        UIView.animate(withDuration: 1) {
            self.frame.origin.y = 0
        }
    }
}

