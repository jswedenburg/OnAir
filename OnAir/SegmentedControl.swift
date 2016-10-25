//
//  SegmentedControl.swift
//  OnAir
//
//  Created by Chandi Abey  on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
//
////inheriting from UIControl and able to drag onto storyboard
//@IBDesignable class SegmentedControl: UIControl
//{
//    
//    
//    //create a labels array and add a label
//    
//    private var labels = [UILabel]()
//    private thumbView = UIView()
//    
//    
//    
//    var items: [String] = ["Search", "Story Queue"] {
//        didSet {
//            setupLabels()
//        }
//    }
//    
//    
//    
//    var selectedIndex: Int = 0 {
//        didSet {
//            displayNewSelectedIndex()
//        }
//    }
//    
//    
//    func setupView() {
//        layer.cornerRadius = frame.height/2
//        layer.borderWidth = 2
//        
//    }
//    
//    
//    func setupLabels() {
//        for label in labels {
//            label.removeFromSuperview()
//        }
//        
//        
//        labels.removeAll(keepingCapacity: true)
//    
//        for index in 1...items.count {
//            //create a label with a rectangle with 0,0
//            let label = UILabel(frame: CGRect.zero)
//            label.text = items[index - 1]
//            label.textAlignment = .center
//            label.textColor = UIColor(white: 0.5, alpha: 1.0)
//            self.addSubview(label)
//            labels.append(label)
//        }
//    }
//    
//    func displayNewSelectedIndex() {
//        var label = labels[selectedIndex]
//        self.thumbView.frame = label.frame
//        
//    }
//    
//    func setupView
//    
//    
//}



