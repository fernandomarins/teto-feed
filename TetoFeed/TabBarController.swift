//
//  TabBarController.swift
//  TetoFeed
//
//  Created by Fernando Augusto de Marins on 14/04/17.
//  Copyright © 2017 Fernando Augusto de Marins. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let feedController = FeedController()
        let navigationController = UINavigationController(rootViewController: feedController)
        navigationController.title = "News Feed"
        navigationController.tabBarItem.image = UIImage(named: "news_feed_icon")
        
        let settingsController = UINavigationController(rootViewController: SettingsController())
        settingsController.title = "Settings"
        settingsController.tabBarItem.image = UIImage(named: "more_icon")
        
        viewControllers = [navigationController, settingsController]
        
        tabBar.isTranslucent = false
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 0.5)
        topBorder.backgroundColor = UIColor.rgb(229, green: 231, blue: 235, alpha: 1).cgColor
        
        tabBar.layer.addSublayer(topBorder)
        tabBar.clipsToBounds = true
        
    }
}
