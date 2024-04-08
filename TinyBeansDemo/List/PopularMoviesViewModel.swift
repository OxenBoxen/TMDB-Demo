//
//  PopularMoviesViewModel.swift
//  TinyBeansDemo
//
//  Created by Matthew Sabath on 3/23/24.
//

import Foundation
import Combine

protocol PopularMoviesViewModelDelegate {
	func didRefreshData()
}

public final class PopularMoviesViewModel {
	
	public enum UIState {
		case initialized
		case fetchingMovies
		case loadedMovies
		case noResults
		case error
	}
	
	public let movieThumbnailPublisher = PassthroughSubject<Result<IndexPath, ServerError>, Never>()
	public let popularMoviesPublisher = PassthroughSubject<Result<Void, ServerError>, Never>()
	
	private var currentSearchResultsPage: Int = 1
	private let networkManager = NetworkManager()
	
	public var currentUIState: UIState = .initialized
	public var movies = [Movie]()
	
	
	// MARK: - Data Fetch
	func fetchPopularMovies() {
		currentUIState = .fetchingMovies
		
		networkManager.fetchPopularMovies(currentPage: currentSearchResultsPage) { [weak self] result in
			
			guard let self = self else {
				return
			}
			
			switch result {
				case .success((let movies)):
					
					self.movies.append(contentsOf: movies)
					self.popularMoviesPublisher.send(.success(Void()))
					self.currentUIState = .loadedMovies
					self.currentSearchResultsPage += 1

				case .failure(let error):
					self.popularMoviesPublisher.send(.failure(ServerError.general))
						// can handle server specific errors as needed
						// for now just send back 'generic' server error
						// log error...
						print(error)
					
					self.currentUIState = .error
			}
		}
	}
	
	func downloadThumbnailFor(_ movie: Movie, indexPath: IndexPath) {
		guard let url = movie.posterUrl else {
			return
		}
		
		networkManager.downloadImage(imageUrl: url) { [weak self] result in
			guard let self else { return }
			
			DispatchQueue.main.async {
				switch result {
					case .success(let image):
						movie.posterImage = image
						self.movieThumbnailPublisher.send(.success(indexPath))
					case .failure(_):
						// already logging error at networkManager level
						// (no need to diplay an alert to user for every failed image download)
						break
				}
			}
		}
	}
}
