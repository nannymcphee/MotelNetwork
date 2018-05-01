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
        NVActivityIndicatorView.DEFAULT_TYPE = .circleStrokeSpin
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
//        NVActivityIndicatorPresenter.sharedInstance.setMessage("Đang tải...")
    }
    
    func stopLoading() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
}

extension String {
    var toDouble: Double {
        return Double(self) ?? 0
    }
}
