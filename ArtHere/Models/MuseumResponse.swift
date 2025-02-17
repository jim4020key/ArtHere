//
//  MuseumResponse.swift
//  ArtHere
//
//  Created by kimjimin on 2/16/25.
//

struct MuseumResponse: Codable {
    let response: Response
    
    struct Response: Codable {
        let header: Header
        let body: Body?
        
        struct Header: Codable {
            let resultCode: String
            let resultMsg: String
        }
        
        struct Body: Codable {
            let items: [Museum]
            let totalCount: String
        }
    }
}
