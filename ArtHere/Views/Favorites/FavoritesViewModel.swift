//
//  FavoritesViewModel.swift
//  ArtHere
//
//  Created by kimjimin on 2/6/25.
//

import Foundation

class FavoritesViewModel {
    private let coreDataManager = CoreDataManager.shared
    private(set) var favoriteMuseums: [FavoriteMuseum] = []
    var onFavoriteRemoved: ((String) -> Void)?
    
    var isEmpty: Bool {
        return favoriteMuseums.isEmpty
    }
    
    func loadFavorites() {
        favoriteMuseums = coreDataManager.fetchFavorites()
    }
    
    func removeFavorite(at index: Int) {
        let museum = favoriteMuseums[index]
        if let name = museum.name {
            coreDataManager.removeFavorite(museumName: name)
            favoriteMuseums.remove(at: index)
            onFavoriteRemoved?(name)
        }
    }
}
