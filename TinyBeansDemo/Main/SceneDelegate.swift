//
//  SceneDelegate.swift
//  TinyBeansDemo
//
//  Created by Matthew Sabath on 3/21/24.
//

import Network
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	private let networkConnectivityMonitor = NetworkConnectivityMonitor()
	
	var window: UIWindow?

	func scene(_ scene: UIScene,
			   willConnectTo session: UISceneSession,
			   options connectionOptions: UIScene.ConnectionOptions) {
		
		if let windowScene = scene as? UIWindowScene {
			
			let window = UIWindow(windowScene: windowScene)
			
			let popularMoviesViewController = PopularMoviesViewController()
			let navigationController = UINavigationController(rootViewController: popularMoviesViewController)
			self.window = window
			
			window.rootViewController = navigationController
			window.makeKeyAndVisible()
			
			setupInternetConnectivityObservers()
		}
	}

	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}

	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
	}
	
	
	// MARK: - Internet Connectivity
	private lazy var noInternetView: UIView = {
		guard let window = window else {
			// shouldn't hit!
			return UIView()
		}
		
		let containerViewSize = CGSize(width: UIScreen.main.bounds.size.width, height: 150.0)
		let wifiImageViewSize = CGSize(width: 60.0, height: 60.0)
		
		let redContainerView = UIView()
		redContainerView.translatesAutoresizingMaskIntoConstraints = false
		redContainerView.backgroundColor = UIColor.red
		
		let noInternetLabel = UILabel()
		noInternetLabel.translatesAutoresizingMaskIntoConstraints = false
		noInternetLabel.text = "Hmmm, it looks like you don't have internet connectivity"
		noInternetLabel.textColor = UIColor.white
		noInternetLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
		noInternetLabel.numberOfLines = 2
		noInternetLabel.textAlignment = .center
		noInternetLabel.lineBreakMode = .byWordWrapping
		
		let wifiImageView = UIImageView(image: UIImage(systemName: "wifi")!)
		wifiImageView.translatesAutoresizingMaskIntoConstraints = false
		wifiImageView.tintColor = UIColor.white
		wifiImageView.contentMode = .scaleAspectFill
		
		redContainerView.addSubview(noInternetLabel)
		redContainerView.addSubview(wifiImageView)
		window.addSubview(redContainerView)
		
		NSLayoutConstraint.activate([
			redContainerView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
			redContainerView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
			redContainerView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
			redContainerView.heightAnchor.constraint(equalToConstant: containerViewSize.height),
			
			noInternetLabel.heightAnchor.constraint(equalToConstant: 50.0),
			noInternetLabel.widthAnchor.constraint(equalToConstant: containerViewSize.width - 50),
			noInternetLabel.centerXAnchor.constraint(equalTo: redContainerView.centerXAnchor),
			noInternetLabel.centerYAnchor.constraint(equalTo: redContainerView.centerYAnchor, constant: 20.0),
			
			wifiImageView.heightAnchor.constraint(equalToConstant: wifiImageViewSize.height),
			wifiImageView.widthAnchor.constraint(equalToConstant: wifiImageViewSize.width),
			wifiImageView.centerXAnchor.constraint(equalTo: redContainerView.centerXAnchor),
			wifiImageView.centerYAnchor.constraint(equalTo: redContainerView.centerYAnchor, constant: -40.0)
		])
		
		return redContainerView
	}()
	
	private func setupInternetConnectivityObservers() {
		
		let defaultNotificationCenter = NotificationCenter.default
		
		defaultNotificationCenter.addObserver(self,
											  selector: #selector(showNoInternetView),
											  name: NSNotification.Name(Constants.kNotificationNoInternet),
											  object: nil)
		
		defaultNotificationCenter.addObserver(self,
											  selector: #selector(hideNoInternetView),
											  name: NSNotification.Name(Constants.kNotificationInternetConnected),
											  object: nil)
	}
	
	@objc private func hideNoInternetView() {
		DispatchQueue.main.async {
			self.noInternetView.isHidden = true
		}
	}
	
	@objc private func showNoInternetView() {
		DispatchQueue.main.async {
			self.noInternetView.isHidden = false
		}
	}
}

