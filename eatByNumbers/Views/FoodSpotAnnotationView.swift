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

    weak var customCalloutView: FoodSpotDetailView?
    
    override var annotation: MKAnnotation? {
        willSet {
            customCalloutView?.removeFromSuperview()
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
        let image = UIImage(named: "foodSpotIcon")
        let resizedImage = image?.resizeImage(targetSize: CGSize(width: 50, height: 50))
        self.image = resizedImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false
        let image = UIImage(named: "foodSpotIcon")
        let resizedImage = image?.resizeImage(targetSize: CGSize(width: 50, height: 50))
        self.image = resizedImage
    }
    
    // MARK: - show/hide callout
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            customCalloutView?.removeFromSuperview()
            
            if let newCustomCalloutView = loadFoodSpotDetailView() {
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2 - (self.frame.width / 2)
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                
                self.addSubview(newCustomCalloutView)
//                self.customCalloutView = newCustomCalloutView
                
                if animated {
                    self.customCalloutView?.alpha = 0.0
                    UIView.animate(withDuration: 0.5) {
                        self.customCalloutView?.alpha = 1.0
                    }
                }
            }
        } else {
            if customCalloutView != nil {
                if animated {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.customCalloutView?.alpha = 0.0
                    }) { (success) in
                        if success {
                            self.customCalloutView?.removeFromSuperview()
                        }
                    }
                } else {
                    self.customCalloutView?.removeFromSuperview()
                }
            }
        }
    }
    
    func loadFoodSpotDetailView() -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 280))
        return view
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customCalloutView?.removeFromSuperview()
    }
}

