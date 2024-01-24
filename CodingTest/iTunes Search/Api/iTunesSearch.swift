//
//  iTunesSearch.swift
//  CodingTest
//
//  Created by banie setijoso on 2024-01-23.
//

import Foundation

enum SearchError: Error {
    case urlInvalid
    case httpError(statusCode: Int, errorMessage: String)
    case parsingError(errorMessage: String, dataInString: String)
    case unexpected(errorMessage: String)
}

protocol iTunesSearchApi {
    func search(for term: String) async -> Result<iTunesSearchResults, SearchError>
}

class iTunesSearchInteractor: iTunesSearchApi {
    
    private let iTunesDomain = "https://itunes.apple.com/search"
    private let decoder: JSONDecoder
    
    init() {
        decoder = JSONDecoder()
    }
    
    func search(for term: String) async -> Result<iTunesSearchResults, SearchError> {
        guard let url = URL(string: iTunesDomain),
              var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return .failure(.urlInvalid)
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "term", value: term), URLQueryItem(name: "limit", value: "2")]
        guard let composedUrl = urlComponents.url else {
            return .failure(.urlInvalid)
        }
        
        let urlRequest = URLRequest(url: composedUrl)
        let sessionResult: (Data, URLResponse)
        do {
            sessionResult = try await URLSession.shared.data(for: urlRequest)
        } catch {
            return .failure(.unexpected(errorMessage: error.localizedDescription))
        }
        
        let data = sessionResult.0
        let urlResponse = sessionResult.1
        if let httpResponse = urlResponse as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 400..<600:
                return .failure(.httpError(statusCode: httpResponse.statusCode, errorMessage: httpResponse.debugDescription))
            default:
                break
            }
        }
        
        do {
            let result = try decoder.decode(iTunesSearchResults.self, from: data)
            return .success(result)
        } catch let DecodingError.dataCorrupted(context) {
            return .failure(.parsingError(errorMessage: context.debugDescription, dataInString: String(decoding: data, as: UTF8.self)))
        } catch let DecodingError.keyNotFound(key, context) {
            return .failure(.parsingError(errorMessage: "Key '\(key)' not found: \(context.debugDescription)", dataInString: String(decoding: data, as: UTF8.self)))
        } catch let DecodingError.valueNotFound(value, context) {
            return .failure(.parsingError(errorMessage: "Value '\(value)' not found: \(context.debugDescription)", dataInString: String(decoding: data, as: UTF8.self)))
        } catch let DecodingError.typeMismatch(type, context)  {
            return .failure(.parsingError(errorMessage: "Type '\(type)' not found: \(context.debugDescription)", dataInString: String(decoding: data, as: UTF8.self)))
        } catch {
            return .failure(.parsingError(errorMessage: error.localizedDescription, dataInString: String(decoding: data, as: UTF8.self)))
        }
    }
}

