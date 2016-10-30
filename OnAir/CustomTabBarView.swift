//
//  CustomTabBarView.swift
//  OnAir
//
//  Created by Jake Swedenburg on 10/30/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class CustomTabBarView: UIView {
    
    weak var delegate: CustomTabBarViewDelegate?

    var imageView0 = UIImageView()
    var imageView1 = UIImageView()
    var imageView2 = UIImageView()
    var imageView3 = UIImageView()
    
    var label0 = UILabel()
    var label1 = UILabel()
    var label2 = UILabel()
    var label3 = UILabel()
    
    var button0 = UIButton()
    var button1 = UIButton()
    var button2 = UIButton()
    var button3 = UIButton()
    
    func selectIndex(index: Int) {
        
        imageView0.tintColor = UIColor.white
        imageView1.tintColor = UIColor.white
        imageView2.tintColor = UIColor.white
        imageView3.tintColor = UIColor.white
        
        label0.textColor = UIColor.red
        label1.textColor = UIColor.red
        label2.textColor = UIColor.red
        label3.textColor = UIColor.red
        
        switch index {
        case 0:
            imageView0.tintColor = UIColor.black
            label0.textColor = UIColor.black
        case 1:
            imageView1.tintColor = UIColor.black
            label1.textColor = UIColor.black
        case 2:
            imageView2.tintColor = UIColor.black
            label2.textColor = UIColor.black
        case 3:
            imageView3.tintColor = UIColor.black
            label3.textColor = UIColor.black
        default:
            break
        }
        
    }
    
    func didTapButton(sender: UIButton) {
        selectIndex(sender.tag)
        delegate?.tabBarButtonPressed(index: sender.tag)
        
    }
    
}


protocol CustomTabBarViewDelegate: class {
    func tabBarButtonPressed(index: Int)
}
