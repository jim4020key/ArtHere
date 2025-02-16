//
//  Museum.swift
//  ArtHere
//
//  Created by kimjimin on 2/2/25.
//

import Foundation

struct Museum: Codable {
    let fcltyNm: String
    let rdnmadr: String
    let homepageUrl: String
    let latitude: String?
    let longitude: String?
    
    var name: String { fcltyNm }
    var address: String { rdnmadr }
    var pageURL: String { homepageUrl }
}
