//
//  ExploreViewModel.swift
//  ArtHere
//
//  Created by kimjimin on 2/2/25.
//

import UIKit

class ExploreViewModel {
    @Published var isCarouselMode = true
    private let coreDataManager = CoreDataManager.shared
    private let networkManager = NetworkManager.shared
    
    var museums: [Museum] = []
    var onMuseumsUpdated: (([Museum]) -> Void)?
    var onError: ((Error) -> Void)?
    
    init() {
        fetchMuseums()
    }
    
    func fetchMuseums() {
        networkManager.fetchMuseums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let museums):
                    self?.museums = museums
                    self?.onMuseumsUpdated?(museums)
                case .failure(let error):
                    self?.onError?(error)
                }
            }
        }
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
