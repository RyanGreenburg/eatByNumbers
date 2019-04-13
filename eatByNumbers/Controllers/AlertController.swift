//
//  AlertController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/3/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class AlertHelper {
    
    static let shared = AlertHelper()
    
    func createAlertControllerWithTitle(_ title: String?, andText text: String?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        return alertController
    }
    
    func blankAlertController(_ title: String?, andText text: String?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        return alertController
    }
    
    func actionableAlertController(_ title: String?, andText text: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        return alertController
    }
}
