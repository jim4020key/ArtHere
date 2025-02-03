//
//  Museum.swift
//  ArtHere
//
//  Created by kimjimin on 2/2/25.
//

struct Museum {
    let name: String
    let pageURL: String
    let address: String
    let longtitute: Double
    let lattitute: Double
}

extension Museum {
    static let sampleData: [Museum] = [
        Museum(
            name: "국립중앙박물관",
            pageURL: "url_example_1",
            address: "서울특별시 용산구 서빙고로 137",
            longtitute: 37.52470233,
            lattitute: 126.9777412
        ),
        Museum(
            name: "국립현대미술관",
            pageURL: "url_example_2",
            address: "서울특별시 종로구 삼청로 30",
            longtitute: 37.57862929,
            lattitute: 126.9800889
        ),
        Museum(
            name: "삼성미술관 리움",
            pageURL: "url_example_3",
            address: "서울특별시 용산구 이태원로55길 60-16",
            longtitute: 37.538461,
            lattitute: 126.999294
        )
    ]
}

