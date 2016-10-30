//
//  TabBarController.swift
//  OnAir
//
//  Created by Jake Swedenburg on 10/30/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, CustomTabBarViewDelegate {
    
    var tabView: CustomTabBarView!
    
    //MARK: View Override Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let name = NSNotification.Name("isAdvertisingChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(showHideTabs(notification:)), name: name, object: nil)
        guard let broadcastMPTab = self.tabBarController?.tabBar.items?[2] else { return }
        broadcastMPTab.isEnabled = false
    }
    
    
    
    
    //MARK: Helper Functions
    func setUpCustomTabBar() {
        let frame = CGRect(x: 0, y: view.frame.height - tabView.frame.height, width: view.frame.width, height: tabView.frame.height)
        tabView = CustomTabBarView(frame: frame)
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
