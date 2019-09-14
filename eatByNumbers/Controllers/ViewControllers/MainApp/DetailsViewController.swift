//
//  DetailsViewController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 9/1/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    weak var delegate: DetailsViewControllerDelegate?
    var foodSpot: FoodSpot?
    var venue: Venue?
    
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

protocol DetailsViewControllerDelegate: class {
    var currentState: State { get set }
    func drawerPanned(recognizer: UIPanGestureRecognizer)
    func panDidEnd()
    func animateForState(_ state: State, view: UIView, edge: CGFloat, to target: CGFloat, velocity: CGFloat)
    func panViews(withPoint panPoint: CGPoint)
}

enum State {
    case open
    case closed
}
