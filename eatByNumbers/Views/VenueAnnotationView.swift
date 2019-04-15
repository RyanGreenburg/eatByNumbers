//
//  VenueAnnotationView.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/15/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import MapKit

class VenueAnnotationView: MKAnnotationView {

    weak var customCalloutView: VenueDetailView?
    weak var venueDetailDelegate: VenueDetailViewDelegate?
    
    override var annotation: MKAnnotation? {
        willSet {
            customCalloutView?.removeFromSuperview()
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
        let image = UIImage(named: "venueIcon")
        let resizedImage = image?.resizeImage(targetSize: CGSize(width: 50, height: 50))
        self.image = resizedImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false
        let image = UIImage(named: "venueIcon")
        let resizedImage = image?.resizeImage(targetSize: CGSize(width: 50, height: 50))
        self.image = resizedImage
    }
    
    // MARK: - show/hide callout
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            customCalloutView?.removeFromSuperview()
            
            if let newCustomCalloutView = loadVenueDetailView() {
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2 - (self.frame.width / 2)
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
                
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
    
    func loadVenueDetailView() -> VenueDetailView? {
        if let views = Bundle.main.loadNibNamed("VenueCallout", owner: self, options: nil) as? [VenueDetailView], views.count > 0 {
            let venueDetailView = views.first!
            venueDetailView.delegate = self.venueDetailDelegate
            if let venueAnnotation = annotation as? VenueAnnotation {
                let venue = venueAnnotation.venue
                venueDetailView.configureWith(venue)
            }
            return venueDetailView
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
