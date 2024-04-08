//
//  NetworkManager.swift
//  TinyBeansDemo
//
//  Created by Matthew Sabath on 3/23/24.
//

import Foundation
import Network
import UIKit

public enum NetworkError: Error {
	case noInternet
}

public enum ServerError: Error {
	case timout
	case serviceDown
	case general
	case noMoreResults
	case imageDownloadFailure
}

enum ApiRequestError: Error {
	case invalidUrl
	case invalidSearchQuery
}

enum ParseError: Error {
	case invalidFormat
}

final class NetworkManager {
	
	private var popularMoviesDataTask: URLSessionDataTask?
	private var movieDetailsDataTask: URLSessionDataTask?
	
	private var downloadingImageUrls = Set<URL>()
	private let decoder = JSONDecoder()
	
	
	lazy var sessionConfiguration: URLSessionConfiguration = {
		let sessionConfiguration = URLSessionConfiguration.default
		sessionConfiguration.httpAdditionalHeaders = [
			"Authorization": "Bearer \(Constants.kApiKeyAccessToken)"
		]
		
		return sessionConfiguration
	}()
	
	lazy var session: URLSession = {
		let session = URLSession(configuration: sessionConfiguration)
		
		return session
	}()
	
	
	// MARK: - Initializers
	init() {
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		
		setupNotificationObservers()
	}
	
	
	// MARK: - Setup
	func setupNotificationObservers() {
		
		let defaultNotificationCenter = NotificationCenter.default
		
		defaultNotificationCenter.addObserver(self,
											  selector: #selector(flushCurrentImageDownloads),
											  name: NSNotification.Name(Constants.kNotificationInternetConnected),
											  object: nil)
	}
	
	
	// Popular Movies
	func downloadImage(imageUrl: URL,
					   completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
		
		guard !downloadingImageUrls.contains(imageUrl) else {
			return
		}
		
		downloadingImageUrls.insert(imageUrl)
		
		DispatchQueue.global(qos: .utility).async {
			do {
				let data = try Data(contentsOf: imageUrl)
				if let image = UIImage(data: data) {
					DispatchQueue.main.async {
						completionHandler(.success(image))
						self.downloadingImageUrls.remove(imageUrl)
					}
				} else {
					// log error...
					self.downloadingImageUrls.remove(imageUrl)
					completionHandler(.failure(ServerError.imageDownloadFailure))
				}
			} catch {
				// log error...
				completionHandler(.failure(ServerError.imageDownloadFailure))
			}
		}
	}
	
	func fetchMovieDetails(movieId: Int,
						   completionHandler: @escaping (Result<Movie, Error>) -> Void) {
	
		movieDetailsDataTask?.cancel()
		
		guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)?append_to_response=similar%2Ccredits&language=en-US") else {
			return completionHandler(.failure(ApiRequestError.invalidUrl))
		}
		
		movieDetailsDataTask = session.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
			
			guard let self else { return }
			
			defer {
				self.movieDetailsDataTask = nil
			}
			
			if let error = error {
				// timout error? Network error? add more logic to handle specific error...
				// log error...
				print(error)
				completionHandler(.failure(ServerError.general))
				return
			}
			
			guard let data = data,
				  let response = response as? HTTPURLResponse
			else {
				completionHandler(.failure(ServerError.general))
				return
			}
			
			if response.statusCode != 200 {
				// here we can handle different status code errors for now, just return general error
				// log error...
				completionHandler(.failure(ServerError.general))
				return
			}
			
			do {
				let movie = try self.parseMovieDetailsDataResponse(data: data)
				completionHandler(.success(movie))

			} catch {
				// Invalid CodingKeys / json format / api response
				// log error...
				completionHandler(.failure(ParseError.invalidFormat))
			}
		}
		
		movieDetailsDataTask?.resume()
	}
	
	func fetchPopularMovies(currentPage: Int,
							completionHandler: @escaping (Result<[Movie], Error>) -> Void) {
		
		popularMoviesDataTask?.cancel()
		
		guard let url = URL(string: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=\(currentPage)") else {
			completionHandler(.failure(ApiRequestError.invalidUrl))
			return
		}
		
		popularMoviesDataTask = session.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
			
			guard let self else { return }
			
			defer {
				self.popularMoviesDataTask = nil
			}
			
			if let error = error {
				// timout error? Network error? add more logic to handle specific error...
				// log error...
				print(error)
				completionHandler(.failure(ServerError.general))
				return
			}
			
			guard let data = data,
					let response = response as? HTTPURLResponse
			else {
				completionHandler(.failure(ServerError.general))
				return
			}
			
			if response.statusCode != 200 {
				// here we can handle different status code errors for now, just return general error
				// log error...
				completionHandler(.failure(ServerError.general))
				return
			}
			
			do {
				let movies = try self.parsePopularMoviesDataResponse(data: data)
				completionHandler(.success(movies))
			} catch {
				// Invalid CodingKeys / json format / api response
				// log error...
				completionHandler(.failure(ParseError.invalidFormat))
			}
		}
		
		popularMoviesDataTask?.resume()
	}
	
	
	// MARK: - Parsing
	private func parsePopularMoviesDataResponse(data: Data) throws -> [Movie] {
		do {
			let response = try decoder.decode(PopularMoviesResponse.self, from: data)
			return response.movies
		} catch {
			throw ParseError.invalidFormat
		}
	}
	
	private func parseMovieDetailsDataResponse(data: Data) throws -> Movie {
		do {
			let movie = try decoder.decode(Movie.self, from: data)
			return movie
		} catch {
			throw ParseError.invalidFormat
		}
	}
	
	
	// MARK: - Private
	@objc private func flushCurrentImageDownloads() {
		
		// refresh in-progress image downloads when internet goes out
		DispatchQueue.main.async {
			self.downloadingImageUrls.removeAll()
		}
	}
}
