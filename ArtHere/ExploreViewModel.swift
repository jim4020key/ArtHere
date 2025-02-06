//
//  ExploreViewModel.swift
//  ArtHere
//
//  Created by kimjimin on 2/2/25.
//

import UIKit

class ExploreViewModel {
    @Published var museums: [Museum] = []
    @Published var isCarouselMode = true
    
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        museums = Museum.sampleData
    }
    
    func toggleViewMode() {
        isCarouselMode.toggle()
    }
    
    func toggleFavorite(for museumName: String) {
        if coreDataManager.isFavorite(museumName: museumName) {
            coreDataManager.removeFavorite(museumName: museumName)
        } else {
            coreDataManager.addFavorite(museumName: museumName)
        }
    }
    
    func isFavorite(museumName: String) -> Bool {
        return coreDataManager.isFavorite(museumName: museumName)
    }
}
