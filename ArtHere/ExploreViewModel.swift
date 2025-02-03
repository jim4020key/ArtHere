//
//  ExploreViewModel.swift
//  ArtHere
//
//  Created by kimjimin on 2/2/25.
//

import Combine
import UIKit

class ExploreViewModel {
    @Published var museums: [Museum] = []
    @Published var isCarouselMode = true
    
    init() {
        museums = Museum.sampleData
    }
    
    func toggleViewMode() {
        isCarouselMode.toggle()
    }
}
