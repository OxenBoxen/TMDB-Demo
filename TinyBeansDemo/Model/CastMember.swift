//
//  CastMember.swift
//  TinyBeansDemo
//
//  Created by Matthew Sabath on 3/27/24.
//

import UIKit

/// CastMember
public struct CastMember: Decodable, Identifiable {
	
	enum CodingKeys: String, CodingKey {
		case id, name, profilePath
	}
	
	public let id: Int
	
	let name: String
	let imageUrl: URL?
	
	// MARK: - Initializer
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		name = try container.decode(String.self, forKey: .name)
		id = try container.decode(Int.self, forKey: .id)
		
		let profileImagePath = try container.decodeIfPresent(String.self, forKey: .profilePath)
		
		if let unwrappedImagePath = profileImagePath {
			imageUrl = URL(string: "\(Constants.tmdbImageBaseUrlPath)\(unwrappedImagePath)")
		} else {
			imageUrl = nil
		}
	}
}

