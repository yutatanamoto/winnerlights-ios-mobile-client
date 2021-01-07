//
//  ViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit

class ViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.barTintColor = UIColor.white
        tabBar.tintColor = UIColor.black
        
        let firstViewController = NavigationController(rootViewController: AvairableExercisesViewController())
        firstViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 0)
        
//        let secondViewController = NavigationController(rootViewController: BLEMeshNetworkViewController())
//        secondViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "dot.radiowaves.left.and.right"), tag: 1)
//
//        let thirdViewController = NavigationController(rootViewController: SettingViewController())
//        thirdViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "slider.horizontal.3"), tag: 2)
        
        self.viewControllers = [
            firstViewController,
//            secondViewController,
//            thirdViewController
        ]
    }
}
