//
//  MarkerInfoView.swift
//  Motel Network
//
//  Created by Nguyên Duy on 5/31/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class MarkerInfoView: UIView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAddress: UILabel!

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MarkerInfoView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
