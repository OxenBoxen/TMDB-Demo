//
//  MovieDetailViewModel.swift
//  TinyBeansDemo
//
//  Created by Matthew Sabath on 3/23/24.
//

import Foundation
import Combine

public final class MovieDetailViewModel: ObservableObject {
	
	public let networkErrorPublisher = PassthroughSubject<Error, Never>()
	
	private let networkManager = NetworkManager()
	
	@Published var relatedMovies = [RelatedMovie]()
	@Published var castMembers = [CastMember]()
	
	let movie: Movie
	
	
	// MARK: - Initializers
	public init(movie: Movie) {
		self.movie = movie
	}
	
	func fetchMovieDetails() {
		networkManager.fetchMovieDetails(movieId: movie.id) { [weak self] result in
			guard let self else { return }
			
			switch result {
				case .success((let movie)):
					DispatchQueue.main.async {
						self.relatedMovies = movie.relatedMovies
						self.castMembers = movie.castMembers
					}
					
				case .failure(let error):
					networkErrorPublisher.send(error)
			}
		}
	}
}
