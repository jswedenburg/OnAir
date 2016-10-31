//
//  CustomTabBarView.swift
//  OnAir
//
//  Created by Jake Swedenburg on 10/30/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

protocol CustomTabBarDataSource {
    func tabBarItemsInCustomTabBar(tabBarView: CustomTabBar) -> [UITabBarItem]
}

protocol CustomTabBarDelegate {
    func didSelectViewController(tabBarView: CustomTabBar, atIndex index: Int)
}


class CustomTabBar: UIView, AdvertisingDelegate {
    
    
    
    //MARK: Properties
    var dataSource: CustomTabBarDataSource!
    var delegate: CustomTabBarDelegate!
    var isAdvertising: Bool = false     
    var tabBarItems: [UITabBarItem]!
    var customTabBarItems: [CustomTabBarItem]!
    var tabBarButtons: [UIButton]!
    
    
    
    //MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        DiscoveryViewController.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init Coder has not been implemented")
    }
    
    //MARK: Target Actions
    func barItemTapped(sender: UIButton) {
        if tabBarButtons.index(of: sender) == 2 {
            if isAdvertising{
                delegate.didSelectViewController(tabBarView: self, atIndex: 2)
            } else {
                delegate.didSelectViewController(tabBarView: self, atIndex: 3)
            }
        } else {
            guard let index = tabBarButtons.index(of: sender) else { return }
            delegate.didSelectViewController(tabBarView: self, atIndex: index)
        }
        
    }
    
    //MARK: Helper Methods
    
    func setup() {
        // get tab bar items from default tab bar
        let defaultBarItems = dataSource.tabBarItemsInCustomTabBar(tabBarView: self)
        
        if isAdvertising {
            tabBarItems = [defaultBarItems[0], defaultBarItems[1], defaultBarItems[2]]
//            indexToShow = [0, 1, 2]
        } else {
            tabBarItems = [defaultBarItems[0], defaultBarItems[1], defaultBarItems[3]]
//            indexToShow = [0, 1, 3]
        }
        
        customTabBarItems = []
        tabBarButtons = []
        
        let containers = createTabBarItemContainers()
        createTabBarItems(containers: containers)
       
        
    }
    
    func createTabBarItemContainers() -> [CGRect] {
        var containerArray = [CGRect]()
        
        //create container ofr each tab bar item
        for index in 0..<tabBarItems.count {
            let tabBarContainer = createTabBarContainer(index: index)
            containerArray.append(tabBarContainer)
        }
        
        return containerArray
        
    }
    
    func createTabBarContainer(index: Int) -> CGRect {
        
        let tabBarContainerWidth = self.frame.width / CGFloat(tabBarItems.count)
        let tabBarContainerRect = CGRect(x: tabBarContainerWidth * CGFloat(index), y: 0, width: tabBarContainerWidth, height: self.frame.height)
        
        return tabBarContainerRect
    }
    
    func createTabBarItems(containers: [CGRect]) {
        var index = 0
        for item in tabBarItems {
            
            
            let container = containers[index]
            let customTabBarItem = CustomTabBarItem(frame: container)
            customTabBarItem.setup(item: item)
            
            self.addSubview(customTabBarItem)
            customTabBarItems.append(customTabBarItem)
            
            let button = UIButton(frame: CGRect(x: container.origin.x, y: container.origin.y, width: container.width, height: container.height))
            
            button.addTarget(self, action: #selector(self.barItemTapped(sender:)), for: UIControlEvents.touchUpInside)
            
            tabBarButtons.append(button)
            self.addSubview(button)
            
            index += 1
        }
        
    }
    
    
    
    
    
}




