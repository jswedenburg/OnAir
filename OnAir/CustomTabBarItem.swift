//
//  CustomTabBarItem.swift
//  OnAir
//
//  Created by Jake Swedenburg on 10/31/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class CustomTabBarItem: UIView {

    var iconView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    func setup(item: UITabBarItem) {
        guard let image = item.image else {
            fatalError("add images to tabbar items")
        }
        
        // create imageView centered within a container 
        iconView = UIImageView(frame: CGRect(x: (self.frame.width - image.size.width) / 2, y: (self.frame.height - image.size.height) / 2, width: self.frame.width, height: self.frame.height))
        iconView.image = image
        iconView.sizeToFit()
        
        self.addSubview(iconView)
    }

}
