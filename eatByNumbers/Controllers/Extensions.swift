//
//  Extensions.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/12/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit


extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension UIButton {
    
    func addShadowTo(button: UIButton) {
        button.layer.shadowRadius = button.frame.width / 2 + 5
        button.layer.shadowColor = Colors.darkGray.color().cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: -0.3)
        button.layer.masksToBounds = false
    }
}
