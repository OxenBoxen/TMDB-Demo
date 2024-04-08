//
//  RelatedMovie.swift
//  TinyBeansDemo
//
//  Created by Matthew Sabath on 3/27/24.
//

import UIKit

/// RelatedMovie
public struct RelatedMovie: Decodable, Identifiable {
	
	enum CodingKeys: String, CodingKey {
		case id, title, posterPath
	}
	
	public let id: Int
	let title: String
	
	let imageUrl: URL?
	
	// MARK: - Initializer
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		title = try container.decode(String.self, forKey: .title)
		id = try container.decode(Int.self, forKey: .id)
		
		let posterImagePath = try container.decodeIfPresent(String.self, forKey: .posterPath)
		
		if let unwrappedPosterPath = posterImagePath {
			imageUrl = URL(string: "\(Constants.tmdbImageBaseUrlPath)\(unwrappedPosterPath)")
		} else {
			imageUrl = nil
		}
	}
}
