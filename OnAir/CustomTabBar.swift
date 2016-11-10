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


class CustomTabBar: UIView {
    
    
    
    //MARK: Properties
    var dataSource: CustomTabBarDataSource!
    var delegate: CustomTabBarDelegate!
    
    var tabBarItems: [UITabBarItem]!
    var customTabBarItems: [CustomTabBarItem]!
    var tabBarButtons: [UIButton]!
    
    var initialTabBarItemIndex: Int!
    var selectedTabBarItemIndex: Int!
    
    
    //MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init Coder has not been implemented")
    }
    
    //MARK: Target Actions
    func barItemTapped(sender: UIButton) {
        //this code allows the selection and deselection of tab bar items and changing colors upon selection and deselection  
        let index = tabBarButtons.index(of: sender)!
        animateTabBarSelection(from: selectedTabBarItemIndex, to: index)
        selectedTabBarItemIndex = index
        delegate.didSelectViewController(tabBarView: self, atIndex: index)
        
        if tabBarButtons.index(of: sender) == 2 {
            if MPCManager.sharedController.isAdvertising{
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
        
        if MPCManager.sharedController.isAdvertising {
            tabBarItems = [defaultBarItems[0], defaultBarItems[1], defaultBarItems[2]]

        } else {
            tabBarItems = [defaultBarItems[0], defaultBarItems[1], defaultBarItems[3]]

        }
        
        customTabBarItems = []
        tabBarButtons = []
        initialTabBarItemIndex = 0
        selectedTabBarItemIndex = initialTabBarItemIndex
        
        let containers = createTabBarItemContainers()
        createTabBarItems(containers: containers)
        
        
       
        
    }
    
    
    
    func animateTabBarSelection(from: Int, to: Int) {
            self.customTabBarItems[from].iconView.tintColor = UIColor.gray
            self.customTabBarItems[to].iconView.tintColor = TeamMusicColor.ourColor
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
        self.customTabBarItems[initialTabBarItemIndex].iconView.tintColor = TeamMusicColor.ourColor
        
    }
    
 
    
    
}




