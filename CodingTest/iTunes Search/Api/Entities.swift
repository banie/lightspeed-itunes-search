//
//  Entities.swift
//  CodingTest
//
//  Created by banie setijoso on 2024-01-23.
//

import Foundation

struct iTunesSearchResults: Codable {
    let resultCount: Int
    let results: [iTunesContent]
}

struct iTunesContent: Codable {
    let wrapperType: String
    let kind: String?
    let trackName: String?
    let artistName: String?
}
