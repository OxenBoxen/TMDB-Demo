//
//  Movie.swift
//  TinyBeansDemo
//
//  Created by Matthew Sabath on 3/23/24.
//

import UIKit

/// PopularMoviesResponse
struct PopularMoviesResponse: Decodable {
	
	enum CodingKeys: String, CodingKey {
		case movies = "results"
	}
	
	let movies: [Movie]
	
	init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.movies = try container.decode([Movie].self, forKey: .movies)
	}
}

/// Movie
final public class Movie: Decodable {
	
	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		return dateFormatter
	}()
	
	enum CodingKeys: String, CodingKey {
		case title, id, posterPath, backdropPath, overview, similar, credits, cast, releaseDate
		case similarMovies = "results"
	}
	
	let releaseDate: Date?
	let overview: String?
	let title: String
	let id: Int
	
	let backdropPosterUrl: URL?
	let posterUrl: URL?
	
	var posterImage: UIImage?
	
	let relatedMovies: [RelatedMovie]
	let castMembers: [CastMember]
	
	// MARK: - Initializer
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		
		let release = try container.decodeIfPresent(String.self, forKey: .releaseDate)
		if let date = release {
			releaseDate = Movie.dateFormatter.date(from: date) ?? nil
		} else {
			releaseDate = nil
		}
		
		overview = try container.decodeIfPresent(String.self, forKey: .overview)
		title = try container.decode(String.self, forKey: .title)
		id = try container.decode(Int.self, forKey: .id)
		
		
		// Image urls
		let posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
		if let unwrappedPosterPath = posterPath {
			posterUrl = URL(string: "\(Constants.tmdbImageBaseUrlPath)\(unwrappedPosterPath)")
		} else {
			posterUrl = nil
		}
		
		let backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
		if let unwrappedBackdropPath = backdropPath {
			backdropPosterUrl = URL(string: "\(Constants.tmdbImageBaseUrlPath)\(unwrappedBackdropPath)")
		} else {
			backdropPosterUrl = nil
		}
		
		// Cast Members
		if container.contains(.credits) {
			let creditsContainer = try container.nestedContainer(keyedBy: CodingKeys.self,
																 forKey: .credits)
			
			castMembers = try creditsContainer.decodeIfPresent([CastMember].self,
																	forKey: .cast) ?? []
		} else {
			castMembers = []
		}
		
		// Related Movies
		if container.contains(.similar) {
			let similarContainer = try container.nestedContainer(keyedBy: CodingKeys.self,
																 forKey: .similar)
			
			relatedMovies = try similarContainer.decodeIfPresent([RelatedMovie].self,
																 forKey: .similarMovies) ?? []
		} else {
			relatedMovies = []
		}
	}
}
