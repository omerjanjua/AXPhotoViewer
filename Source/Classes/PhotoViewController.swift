//
//  PhotoViewController.swift
//  Pods
//
//  Created by Alex Hill on 5/7/17.
//
//

import UIKit
import FLAnimatedImage

@objc(BAPPhotoViewController) class PhotoViewController: UIViewController {
    
    fileprivate weak var notificationCenter: NotificationCenter?

    var pageIndex: Int = 0
    fileprivate var photo: Photo?
    fileprivate var imageView = UIImageView()
    
    var loadingView: LoadingViewProtocol? {
        didSet {
            self.view.setNeedsLayout()
        }
    }
    
    init(loadingView: LoadingViewProtocol, notificationCenter: NotificationCenter) {
        self.loadingView = loadingView
        self.notificationCenter = notificationCenter
        
        super.init(nibName: nil, bundle: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(photoLoadingProgressDidUpdate(_:)),
                                       name: .photoLoadingProgressUpdate,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(photoImageDidUpdate(_:)),
                                       name: .photoImageUpdate,
                                       object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.notificationCenter?.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        (self.loadingView as? UIView)?.frame = self.view.bounds
    }
    
    func applyPhoto(_ photo: Photo) {
        self.photo = photo
        self.imageView.image = photo.image
    }
    
    // MARK: - Notifications
    @objc fileprivate func photoLoadingProgressDidUpdate(_ notification: Notification) {
        guard let photo = notification.object as? Photo else {
            assertionFailure("Photos must conform to the BAPhoto protocol.")
            return
        }
        
        guard photo === self.photo, let progress = notification.userInfo?[PhotosViewControllerNotification.ProgressKey] as? Progress else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.loadingView?.updateProgress?(percent: progress.fractionCompleted)
        }
    }
    
    @objc fileprivate func photoImageDidUpdate(_ notification: Notification) {
        guard let photo = notification.object as? Photo else {
            assertionFailure("Photos must conform to the BAPhoto protocol.")
            return
        }
        
        guard photo === self.photo else {
            return
        }
        
        if let image = notification.userInfo?[PhotosViewControllerNotification.ImageKey] as? UIImage {
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = image
                (self?.loadingView as? UIView)?.removeFromSuperview()
            }
        } else if let error = notification.userInfo?[PhotosViewControllerNotification.ImageKey] as? NSError {
            DispatchQueue.main.async { [weak self] in
                // update views
            }
        }
    }

}
