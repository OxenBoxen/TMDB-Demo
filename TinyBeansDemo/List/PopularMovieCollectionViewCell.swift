//
//  PopularMovieCollectionViewCell.swift
//  TinyBeansDemo
//
//  Created by Matthew Sabath on 3/23/24.
//

import UIKit

final class PopularMovieCollectionViewCell: UICollectionViewCell {

	static let reuseIdentifier = String(describing: PopularMovieCollectionViewCell.self)
	
	@IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
	@IBOutlet private weak var movieImageView: UIImageView!
	@IBOutlet private weak var titleLabel: UILabel!
	
	
	// MARK: - Override
    override func awakeFromNib() {
        super.awakeFromNib()
        
		activityIndicatorView.startAnimating()
		activityIndicatorView.isHidden = false
		movieImageView.layer.cornerRadius = 6.0
		movieImageView.image = nil
		titleLabel.text = "" 
    }
	
	// MARK: - Setup
	func setupWith(_ movie: Movie) {
		titleLabel.text = movie.title
		movieImageView.image = nil 
	}
	
	
	// MARK: - Update
	func updateWithImage(_ image: UIImage) {
		activityIndicatorView.stopAnimating()
		activityIndicatorView.isHidden = true
		movieImageView.image = image
	}
}
