//
//  TabBarController.swift
//  OnAir
//
//  Created by Jake Swedenburg on 10/30/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, CustomTabBarViewDelegate {
    
       
    var tabView: CustomTabBarView!
    
    override var selectedIndex: Int {
        didSet {
            tabView.selectIndex(index: selectedIndex)
        }
    }
    
    //MARK: Custom TabBar Delegate
    func tabBarButtonPressed(index: Int) {
        selectedIndex = index
    }
    
    //MARK: Custom TabbBar Datasource
    
    func tabBarItemsInCustomTabBar(tabBarView: CustomTabBarView) -> [UITabBarItem] {
        return tabBar.items!
    }
    
    //MARK: View Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCustomTabBar()
        tabView.delegate = self
        
        
        
        
        
//        let name = NSNotification.Name("isAdvertisingChanged")
//        NotificationCenter.default.addObserver(self, selector: #selector(showHideTabs(notification:)), name: name, object: nil)
//        guard let broadcastMPTab = self.tabBarController?.tabBar.items?[2] else { return }
//        broadcastMPTab.isEnabled = false
    }
    
    
    
    
    //MARK: Helper Functions
    func setUpCustomTabBar() {
        tabBar.isHidden = true
//        let frame = CGRect(x: 0, y: view.frame.height - tabBar.frame.height, width: view.frame.width, height: tabBar.frame.height)
        tabView = CustomTabBarView(frame: tabBar.frame)
        tabView.delegate = self
        tabView.selectIndex(index: 0)
        view.addSubview(tabView)
    }
    
    func showHideTabs(notification: Notification) {
        guard let tabBarController = self.tabBarController else { return }
        guard let isAdvertising = notification.object as? Bool else { return }
        guard let listenerMPTab = self.tabBarController?.tabBar.items?[3] else { return }
        guard let broadcastMPTab = self.tabBarController?.tabBar.items?[2] else { return }
        if isAdvertising {
            listenerMPTab.isEnabled = false
            broadcastMPTab.isEnabled = true
        } else {
            listenerMPTab.isEnabled = true
            broadcastMPTab.isEnabled = false
        }
    }
    
}


