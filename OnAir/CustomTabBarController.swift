//
//  TabBarController.swift
//  OnAir
//
//  Created by Jake Swedenburg on 10/30/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, CustomTabBarDataSource, CustomTabBarDelegate {
    
  
    //MARK: Custom TabBar Delegate and Datasource
    func tabBarItemsInCustomTabBar(tabBarView: CustomTabBar) -> [UITabBarItem] {
        return tabBar.items!
    }
    
    func didSelectViewController(tabBarView: CustomTabBar, atIndex index: Int) {
        self.selectedIndex = index
    }
    
    
    
    //MARK: View Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCustomTabBar()
        let name = NSNotification.Name("isAdvertisingChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(setUpCustomTabBar), name: name, object: nil)
    }
    
    
 
  
    
    
    //MARK: Helper Functions
    func setUpCustomTabBar() {
        tabBar.isHidden = true
        let customTabBar = CustomTabBar(frame: self.tabBar.frame)
        customTabBar.dataSource = self
        customTabBar.delegate = self
        customTabBar.setup()
        
        
        self.view.addSubview(customTabBar)
    }
    
}


