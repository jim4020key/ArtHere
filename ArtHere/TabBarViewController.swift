//
//  TabBarViewController.swift
//  ArtHere
//
//  Created by kimjimin on 1/31/25.
//

import UIKit

final class TabBarViewController: UITabBarController {
    static let defaultAppearance: UINavigationBarAppearance = {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .base
        return appearance
    }()
    
    static let scrollViewNavigationBarAppearance: UINavigationBarAppearance = {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        return appearance
    }()
    
    static let scrollViewTabBarAppearance: UITabBarAppearance = {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        return appearance
    }()
    
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
        favoritesViewController.setOnFavoriteRemoved { [weak exploreViewController] _ in
            exploreViewController?.reloadCollectionView()
        }
        
        let exploreNavController = UINavigationController(rootViewController: exploreViewController)
        let favoritesNavController = UINavigationController(rootViewController: favoritesViewController)
        exploreNavController.navigationBar.tintColor = .primary
        favoritesNavController.navigationBar.tintColor = .primary
        
        viewControllers = [exploreNavController, favoritesNavController]
        
        tabBar.tintColor = .primary
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = .white
    }
}
