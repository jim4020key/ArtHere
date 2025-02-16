//
//  NetworkManager.swift
//  ArtHere
//
//  Created by kimjimin on 2/11/25.
//

import Foundation
import os

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case apiError(message: String)
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://api.data.go.kr/openapi/tn_pubr_public_museum_artgr_info_api"
    private let apiKey = APIKey.removingPercentEncoding
    private init() {}
    
#if DEBUG
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Network")
#endif
    
    func fetchMuseums(completion: @escaping (Result<[Museum], Error>) -> Void) {
        let urlString = "\(baseURL)?serviceKey=\(APIKey)&pageNo=1&numOfRows=10&type=json"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
#if DEBUG
        logger.debug("Request URL: \(url.absoluteString)")
#endif
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
#if DEBUG
            if let responseString = String(data: data, encoding: .utf8) {
                self.logger.debug("Response: \(responseString)")
            }
#endif
            
            do {
                let museumResponse = try JSONDecoder().decode(MuseumResponse.self, from: data)
                if museumResponse.response.header.resultCode == "00" {
                    completion(.success(museumResponse.response.body?.items ?? []))
                } else {
                    completion(.failure(NetworkError.apiError(message: museumResponse.response.header.resultMsg)))
                }
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
}
