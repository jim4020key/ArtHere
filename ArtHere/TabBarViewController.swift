//
//  TabBarViewController.swift
//  ArtHere
//
//  Created by kimjimin on 1/31/25.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let exploreViewController = ExploreViewController()
        let exploreTabBarItem = UITabBarItem(
            title: "둘러보기",
            image: UIImage(systemName: "location.circle"),
            tag: 0
        )
        exploreTabBarItem.selectedImage = UIImage(systemName: "location.circle.fill")
        exploreViewController.tabBarItem = exploreTabBarItem
        
        let favoritesViewController = FavoritesViewController()
        let favoritesTabBarItem = UITabBarItem(
            title: "관심",
            image: UIImage(systemName: "heart.circle"),
            tag: 1
        )
        favoritesTabBarItem.selectedImage = UIImage(systemName: "heart.circle.fill")
        favoritesViewController.tabBarItem = favoritesTabBarItem
        
        let exploreNavController = UINavigationController(rootViewController: exploreViewController)
        let favoritesNavController = UINavigationController(rootViewController: favoritesViewController)
        
        viewControllers = [exploreNavController, favoritesNavController]
        
        tabBar.tintColor = .primary
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = .white
    }
}
