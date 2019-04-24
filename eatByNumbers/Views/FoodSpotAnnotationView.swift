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
    weak var foodSpotDetailDelegate: FoodSpotDetailViewDelegate?
    
    override var annotation: MKAnnotation? {
        willSet {
            customCalloutView?.removeFromSuperview()
        }
    }
    
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
        
        if selected {
            customCalloutView?.removeFromSuperview()
            
            if let newCustomCalloutView = loadFoodSpotDetailView() {
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2 - (self.frame.width / 2)
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
                
                if animated {
                    self.customCalloutView?.alpha = 0.0
                    UIView.animate(withDuration: 0.1) {
                        self.customCalloutView?.alpha = 1.0
                    }
                }
            }
        } else {
            if customCalloutView != nil {
                if animated {
                    UIView.animate(withDuration: 0.1, animations: {
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
    
    func animateDrop() {
        self.frame.origin.y = -1000
        UIView.animate(withDuration: 1) {
            self.frame.origin.y = 0
        }
    }
    
    func loadFoodSpotDetailView() -> FoodSpotDetailView? {
        if let views = Bundle.main.loadNibNamed("FoodSpotCallout", owner: self, options: nil) as? [FoodSpotDetailView], views.count > 0 {
            let foodSpotDetailView = views.first!
            foodSpotDetailView.delegate = self.foodSpotDetailDelegate
            if let foodSpotAnnotation = annotation as? FoodSpotAnnotation {
                let foodSpot = foodSpotAnnotation.foodSpot
                foodSpotDetailView.configureWith(foodSpot)
            }
            foodSpotDetailView.layer.cornerRadius = foodSpotDetailView.frame.height / 4
            foodSpotDetailView.backgroundColor = Colors.lightGray.color()
            return foodSpotDetailView
        }
        return nil
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if super passed hit test, return the result
        if let parentHitView = super.hitTest(point, with: event) { return parentHitView }
        else { // test in our custom callout.
            if customCalloutView != nil {
                return customCalloutView!.hitTest(convert(point, to: customCalloutView!), with: event)
            } else { return nil }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customCalloutView?.removeFromSuperview()
    }
}

