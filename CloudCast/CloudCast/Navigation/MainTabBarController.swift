//
//  MainTabBarController.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 30/03/26.
//

//import UIKit
//
//final class MainTabBarController: UITabBarController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        setupTabs()
//    }
//
//    private func setupTabs() {
//        // Placeholder — Home, Search, Settings screens come next
//        let homeVC = UIViewController()
//        homeVC.view.backgroundColor = .systemBackground
//        homeVC.tabBarItem = UITabBarItem(
//            title: "Home",
//            image: UIImage(systemName: "house"),
//            selectedImage: UIImage(systemName: "house.fill")
//        )
//
//        let searchVC = UIViewController()
//        searchVC.tabBarItem = UITabBarItem(
//            title: "Search",
//            image: UIImage(systemName: "magnifyingglass"),
//            selectedImage: nil
//        )
//
//        let settingsVC = UIViewController()
//        settingsVC.tabBarItem = UITabBarItem(
//            title: "Settings",
//            image: UIImage(systemName: "gearshape"),
//            selectedImage: UIImage(systemName: "gearshape.fill")
//        )
//
//        viewControllers = [homeVC, searchVC, settingsVC]
//    }
//}


import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupTabBarAppearance()
    }

    private func setupTabs() {
        let homeVC = UINavigationController(
            rootViewController: HomeViewController()
        )
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let searchVC = UINavigationController(
            rootViewController: UIViewController() // placeholder
        )
        searchVC.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: nil
        )

        let settingsVC = UINavigationController(
            rootViewController: UIViewController() // placeholder
        )
        settingsVC.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )

        viewControllers = [homeVC, searchVC, settingsVC]
    }

    private func setupTabBarAppearance() {
        tabBar.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .secondaryLabel
    }
}
