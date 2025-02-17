//
//  MuseumDetailViewModel.swift
//  ArtHere
//
//  Created by kimjimin on 2/10/25.
//

import Foundation

class MuseumDetailViewModel {
    private let museum: Museum
    private let coreDataManager = CoreDataManager.shared
    var onFavoriteToggled: (() -> Void)?
    
    var museumName: String { museum.name }
    var homepageURL: String { museum.pageURL }
    
    init(museum: Museum) {
        self.museum = museum
    }
    
    func toggleFavorite() {
        if isFavorite() {
            coreDataManager.removeFavorite(museumName: museum.name)
        } else {
            coreDataManager.addFavorite(museumName: museum.name)
        }
        onFavoriteToggled?()
    }
    
    func isFavorite() -> Bool {
        return coreDataManager.isFavorite(museumName: museum.name)
    }
}
