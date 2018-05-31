//
//  TableViewHelper.swift
//  Motel Network
//
//  Created by Nguyên Duy on 5/25/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func setEmptyMessage(_ message: String) {
        guard self.numberOfRows() == 0 else {
            return
        }
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16.0)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func showEmptyDataView(message: String, image: UIImage) {
        guard self.numberOfRows() == 0 else {
            return
        }
        
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 10
        
        let emptyImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 140, height: 140))

        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyImageView.widthAnchor.constraint(equalToConstant: 140).isActive = true
        emptyImageView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        emptyImageView.image = image

        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))

        messageLabel.text = message
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16.0)
        messageLabel.sizeToFit()
        
        stackView.addArrangedSubview(emptyImageView)
        stackView.addArrangedSubview(messageLabel)
        bgView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: bgView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
        
        self.backgroundView = bgView
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
    
    public func numberOfRows() -> Int {
        var section = 0
        var rowCount = 0
        while section < numberOfSections {
            rowCount += numberOfRows(inSection: section)
            section += 1
        }
        return rowCount
    }
}
