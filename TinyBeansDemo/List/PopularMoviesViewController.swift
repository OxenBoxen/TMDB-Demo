//
//  PopularMoviesViewController.swift
//  TinyBeansDemo
//
//  Created by Matthew Sabath on 3/23/24.
//

import SwiftUI
import Combine
import UIKit

final class PopularMoviesViewController: UIViewController {
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	private var subscriptions = Set<AnyCancellable>()
	private var viewModel = PopularMoviesViewModel()
	

	// MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupUI()
		setupNotificationObservers()
		bindViewModelPublishers()
		fetchPopularMoviesData()
    }
	
	
	// MARK: - Setup
	func setupUI() {
		self.title = "Popular Movies"
		
		collectionView.register(UINib(nibName: PopularMovieCollectionViewCell.reuseIdentifier, bundle: nil),
								forCellWithReuseIdentifier: PopularMovieCollectionViewCell.reuseIdentifier)
		
		let fraction: CGFloat = 1 / 2
		let inset: CGFloat = 0.5
		
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction),
											  heightDimension: .fractionalHeight(1))
		
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											   heightDimension: .fractionalHeight(fraction))
		
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
													   subitems: [item])
		
		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: inset,	leading: inset,	bottom: inset, trailing: inset)
		
		collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
	}
	
	func setupNotificationObservers() {
		NotificationCenter.default.addObserver(self,
											   selector: #selector(displayRefreshButton),
											   name: NSNotification.Name(Constants.kNotificationNoInternet),
											   object: nil)
	}
	
	func bindViewModelPublishers() {
		let moviesCancellable = viewModel.popularMoviesPublisher.sink { result in
			
			DispatchQueue.main.async {
				switch result {
					case .success():
						self.collectionView.reloadData()
						self.navigationItem.rightBarButtonItems = []
						
					case .failure(_):
						// can display different alerts depending on server error
						// for now, just display general error and refresh button
						self.throwProblemFetchingMoviesAlert()
						self.displayRefreshButton()
				}
			}
		}
		
		let thumbanilCancellable = viewModel.movieThumbnailPublisher.sink { result in
			
			DispatchQueue.main.async {
				switch result {
					case .success(let indexPath):
						self.collectionView.reloadItems(at: [indexPath])
						
					case .failure(_):
						// no need to alert user of failed image download
						// nice to have (future) add in way to redownload specific image from cell
						break
				}
			}
		}
		
		subscriptions.insert(moviesCancellable)
		subscriptions.insert(thumbanilCancellable)
	}
	
	
	// MARK: - UI Update
	@objc func displayRefreshButton() {
		let refresh = UIBarButtonItem(title: "Refresh",
									  style: .plain,
									  target: self,
									  action: #selector(fetchPopularMoviesData))
		
		navigationItem.rightBarButtonItems = [refresh]
	}
	
	
	// MARK: - Data
	@objc func fetchPopularMoviesData() {
		viewModel.fetchPopularMovies()
	}
	
	// MARK: - Private
	private func throwProblemFetchingMoviesAlert() {
		let alertController = UIAlertController(title: "Uh Oh",
												message: "We're sorry, something went wrong trying to fetch popular movies. Please tap the Refresh button to try again",
												preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: "OK", style: .default)
		
		alertController.addAction(okAction)
		
		present(alertController, animated: true)
	}
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PopularMoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		return viewModel.movies.count
	}
	
	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularMovieCollectionViewCell.reuseIdentifier,
													  for: indexPath) as! PopularMovieCollectionViewCell
		let movie = viewModel.movies[indexPath.row]
		
		cell.setupWith(movie)

		if let thumbnail = movie.posterImage {
			cell.updateWithImage(thumbnail)
		} else {
			viewModel.downloadThumbnailFor(movie, indexPath: indexPath)
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView,
						didSelectItemAt indexPath: IndexPath) {
		
		let movie = viewModel.movies[indexPath.row]
		let detailView = MovieDetailView(movie: movie)
		let vc = UIHostingController(rootView: detailView)
		
		navigationController?.pushViewController(vc, animated: true)
	}
	
	func collectionView(_ collectionView: UICollectionView,
						willDisplay cell: UICollectionViewCell,
						forItemAt indexPath: IndexPath) {
		
		if (indexPath.row == viewModel.movies.count - 10 ) {
			if viewModel.currentUIState != .fetchingMovies {
				fetchPopularMoviesData()
			}
		}
	}
}
