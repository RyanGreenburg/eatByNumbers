//
//  Colors.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/8/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

enum Colors {
    case lightBlue
    case darkBlue
    case darkGray
    case lightGray
    case white
    case offWhite
    
    func color() -> UIColor {
        switch self {
        case .lightBlue:
            return UIColor(red: 23/255.0, green: 178/255.0, blue: 237/255.0, alpha: 1.0)
        case .darkBlue:
            return UIColor(red: 43/255.0, green: 121/255.0, blue: 160/255.0, alpha: 1.0)
        case .darkGray:
            return UIColor(red: 15/255.0, green: 15/255.0, blue: 15/255.0, alpha: 1.0)
        case .lightGray:
            return UIColor(red: 50/255.0, green: 51/255.0, blue: 53/255.0, alpha: 1.0)
        case .white:
            return UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        case .offWhite:
            return UIColor(red: 180/255.0, green: 183/255.0, blue: 185/255.0, alpha: 1.0)
        }
    }
}
