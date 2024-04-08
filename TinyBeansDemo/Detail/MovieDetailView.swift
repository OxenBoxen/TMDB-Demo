//
//  MovieDetailView.swift
//  TinyBeansDemo
//
//  Created by Matthew Sabath on 3/23/24.
//


import SwiftUI

/// MovieDetailView
struct MovieDetailView: View {
	
	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d, yyyy"
		
		return dateFormatter
	}()
	
	@ObservedObject var viewModel: MovieDetailViewModel
	@State private var dataFetchErrorAlert = false
	
	private let internetConnectedPublisher = NotificationCenter.default.publisher(for: Notification.Name(Constants.kNotificationInternetConnected))
	
	
	// MARK: - Initializers
	public init(movie: Movie) {
		viewModel = MovieDetailViewModel(movie: movie)
		viewModel.fetchMovieDetails()
	}
	
	var body: some View {
		List {
			MoviePosterView(movie: viewModel.movie)
			MovieMetadataView(movie: viewModel.movie)
			VStack {
				HeaderTextView(headerText: "Cast Members:")
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(spacing: 15) {
						ForEach(viewModel.castMembers) { castMember in
							CastMemberView(castMember: castMember)
						}
					}
				}
				.frame(height: 150)
				HeaderTextView(headerText: "Related Movies:")
					.padding(.bottom, 15.0)
				ForEach(viewModel.relatedMovies) { relatedMovie in
					RelatedMovieView(relatedMovie: relatedMovie)
				}
			}
		}
		.listStyle(.plain)
		.alert("Uh Oh", isPresented: $dataFetchErrorAlert, actions: {
			Button("OK", role: .cancel) { }
		}, message: {
			Text("There was a problem fetching movie details. Please try again")
		})
		.navigationBarTitle(viewModel.movie.title, displayMode: .inline)
		.onReceive(internetConnectedPublisher) { (output) in
			viewModel.fetchMovieDetails()
		}
		.onReceive(viewModel.networkErrorPublisher) { (output) in
			dataFetchErrorAlert = true
		}
	}
	
	
	/// MoviePosterView
	struct MoviePosterView: View {
		
		private let movie: Movie
		
		init(movie: Movie) {
			self.movie = movie
		}
		
		var body: some View {
			ZStack {
				if let backdropPosterUrl = movie.backdropPosterUrl {
					AsyncImage(url: backdropPosterUrl) { image in
						image
							.resizable()
							.aspectRatio(contentMode: .fill)
							.opacity(0.2)
					} placeholder: {
						EmptyView()
					}
				}
				
				if let image = movie.posterImage {
					HStack {
						Spacer()
						Image(uiImage: image)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.clipShape(RoundedRectangle(cornerRadius: 6.0))
							.frame(width: 200, height: 300)
						Spacer()
					}
				} else {
					if let posterUrl = movie.posterUrl {
						HStack {
							Spacer()
							AsyncImage(url: posterUrl) { image in
								image
									.resizable()
									.aspectRatio(contentMode: .fit)
									.clipShape(RoundedRectangle(cornerRadius: 6.0))
									.frame(width: 200, height: 300)
							} placeholder: {
								EmptyView()
							}
							Spacer()
						}
					}
				}
			}
		}
	}
	
	
	/// MovieMetadataView
	struct MovieMetadataView: View {
		private let movie: Movie
		
		init(movie: Movie) {
			self.movie = movie
		}
		
		var body: some View {
			if let overview = movie.overview {
				HeaderTextView(headerText: "Synopsis:")
				Text(overview)
					.multilineTextAlignment(.leading)
			}
			
			if let releaseDate = movie.releaseDate {
				HStack {
					Image(systemName: "calendar")
					Text(MovieDetailView.dateFormatter.string(from: releaseDate))
					Spacer()
				}
			}
		}
	}
	
	/// CastMemberView
	struct CastMemberView: View {
		private let castMember: CastMember
		
		init(castMember: CastMember) {
			self.castMember = castMember
		}
		
		var body: some View {
			VStack {
				Spacer()
				if let imageUrl = castMember.imageUrl {
					AsyncImage(url: imageUrl) { image in
						image
							.resizable()
							.aspectRatio(contentMode: .fill)
							.clipShape(Circle())
							.frame(width: 100.0, height: 100.0)
					} placeholder: {
						ProgressView()
					}
				} else {
					ZStack {
						Color(.lightGray)
						Text("(no photo)")
					}
					.clipShape(Circle())
					.frame(width: 100.0, height: 100.0)
				}
				Text(castMember.name)
				Spacer()
			}
		}
	}
	
	
	/// RelatedMovieView
	struct RelatedMovieView: View {
		private let relatedMovie: RelatedMovie
		
		init(relatedMovie: RelatedMovie) {
			self.relatedMovie = relatedMovie
		}
		
		var body: some View {
			VStack {
				Spacer()
				if let imageUrl = relatedMovie.imageUrl {
					
					AsyncImage(url: imageUrl) { image in
						image
							.resizable()
							.aspectRatio(contentMode: .fit)
							.clipShape(RoundedRectangle(cornerRadius: 6.0))
						
					} placeholder: {
						ProgressView()
					}
				} else {
					ZStack {
						Color(.lightGray)
							.clipShape(RoundedRectangle(cornerRadius: 6.0))
						Text("(no movie poster found)")
					}
				}
				Text(relatedMovie.title)
					.font(.system(size: 20))
					.bold()
				Spacer()
			}
			.padding(.bottom, 25.0)
		}
	}
	
	
	/// HeaderTextView
	struct HeaderTextView: View {
		private let headerText: String
		
		init(headerText: String) {
			self.headerText = headerText
		}
		
		var body: some View {
			HStack {
				Text(headerText)
					.font(.system(size: 20))
					.bold()
				Spacer()
			}
			.padding(.top, 25.0)
		}
	}
}
