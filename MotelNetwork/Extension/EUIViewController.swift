//
//  EUIViewController.swift
//  MotelNetwork
//
//  Created by Nguyen Seven on 4/5/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

extension UIViewController {
    func showLoading() {
        let activityData = ActivityData()
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
    
    func stopLoading() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    func makeButtonRounded(button: UIButton) {
        button.layer.cornerRadius = button.frame.height / 2.0
        button.clipsToBounds = true
    }
    
    func makeImageViewRounded(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.width / 2.0
        imageView.clipsToBounds = true
    }
}
