//
//  SegmentedControlViewController.swift
//  OnAir
//
//  Created by Chandi Abey  on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class SegmentedControlViewController: UIViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //look for taps
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SegmentedControlViewController.dismissKeyboard))
        //tap will not interfere with or cancel other interactions
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        //remove all borders and colors from the apple provided segmented control, see extension below
        segmentedControl.removeBorders()
        
        //change text font and color of the segmented control titles
        segmentedControl.setFontSize(fontSize: 16)
        
        
        
        //let titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        //self.segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 225/270, green: 232/270, blue: 237/270, alpha: 1.0)
    
    }
    
    
  
    
    
    
    //function called when tap is recognized
    func dismissKeyboard() {
        //causes view to resign first responder status
        view.endEditing(true)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
//        if MPCManager.sharedController.isAdvertising {
//            self.segmentedControl.setEnabled(true, forSegmentAt: 1)
//        } else {
//            self.segmentedControl.setEnabled(false, forSegmentAt: 1)
//        }
        
        //default, add border color to search segment before selection is made 
//        self.segmentedControl.selectedSegmentIndex = 0
        if segmentedControl.selectedSegmentIndex == 0 {
            self.setupBorder()
        } else {
            self.parent?.navigationItem.rightBarButtonItem?.isEnabled = true
            self.parent?.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        }
        
        
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var songQueueView: UIView!
    
    
    
    
    var bottomBorder = CALayer()
    
    @IBAction func showComponent(sender: UISegmentedControl) {
        
        
        
//        bottomBorder.borderColor = UIColor.blue.cgColor
//        bottomBorder.borderWidth = 3
  //      bottomBorder.frame = CGRect(x: 0, y: self.segmentedControl.frame.size.height - bottomBorder.borderWidth, width: self.segmentedControl.frame.size.width, height: bottomBorder.borderWidth)
//        self.segmentedControl.layer.addSublayer(bottomBorder)
        
        
        if sender.selectedSegmentIndex == 0 {
            self.parent?.navigationItem.rightBarButtonItem?.isEnabled = false
            self.parent?.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
            UIView.animate(withDuration: 0.5, animations: {
                self.searchView.alpha = 1
                self.songQueueView.alpha = 0
                self.setupBorder()
                
                
                
                
            })
        } else if sender.selectedSegmentIndex == 1 {
            self.parent?.navigationItem.rightBarButtonItem?.isEnabled = true
            self.parent?.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
            UIView.animate(withDuration: 0.5, animations: {
                self.searchView.alpha = 0
                self.songQueueView.alpha = 1
                
                self.setupBorder()
            })
        }
            
            
    }
    
    func setupBorder() {
        //Remove SuperLayer when segment is selected
        self.bottomBorder.removeFromSuperlayer()
        // Creating new layer for selection
        self.bottomBorder = CALayer()
        self.bottomBorder.borderColor = TeamMusicColor.ourColor.cgColor
        self.bottomBorder.borderWidth = 6
        // Calculating frame
        let width: CGFloat = self.segmentedControl.frame.size.width / 2
        let x: CGFloat = CGFloat(self.segmentedControl.selectedSegmentIndex)
            * width
        let y: CGFloat = self.segmentedControl.frame.size.height - self.bottomBorder.borderWidth
        self.bottomBorder.frame = CGRect(x: x, y: y, width: width, height: self.bottomBorder.borderWidth)
        // Adding selection to segment
        self.segmentedControl.layer.addSublayer(self.bottomBorder)

    }
}



extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: UIColor.clear), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: UIColor.clear), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 2.0, height: 44.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
    
    
 
        
    func setFontSize(fontSize: CGFloat) {
            
            let normalTextAttributes: [String : AnyObject] = [
                NSForegroundColorAttributeName: TeamMusicColor.ourColor,
                NSFontAttributeName: UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightMedium)
            ]
            
            let boldTextAttributes: [String : AnyObject] = [
                NSForegroundColorAttributeName : TeamMusicColor.ourColor,
                NSFontAttributeName : UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightBold),
                ]
            
            self.setTitleTextAttributes(normalTextAttributes, for: .normal)
            self.setTitleTextAttributes(normalTextAttributes, for: .highlighted)
            self.setTitleTextAttributes(boldTextAttributes, for: .selected)
    }
    
    
}





extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
}
