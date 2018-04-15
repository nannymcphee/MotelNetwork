//
//  EditPostViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/15/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class EditPostViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var ivPostImage0: UIImageView!
    @IBOutlet weak var ivPostImage1: UIImageView!
    @IBOutlet weak var ivPostImage2: UIImageView!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfDistrict: UITextField!
    @IBOutlet weak var tfRoomPrice: UITextField!
    @IBOutlet weak var tfElectricPrice: UITextField!
    @IBOutlet weak var tfWaterPrice: UITextField!
    @IBOutlet weak var tfInternetPrice: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var tfArea: UITextField!

    var currentNews = News()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapToDismissKeyboard()
        setUpView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set up view
    func setUpView() {
        
        tfTitle.text = currentNews.title
        tvDescription.text = currentNews.description
        tfAddress.text = currentNews.address
        tfDistrict.text = currentNews.district
        tfRoomPrice.text = "\(currentNews.price ?? 0.0)"
        tfElectricPrice.text = "\(currentNews.electricPrice ?? 0.0)"
        tfWaterPrice.text = "\(currentNews.waterPrice ?? 0.0)"
        tfInternetPrice.text = "\(currentNews.internetPrice ?? 0.0)"
        tfPhoneNumber.text = currentNews.phoneNumber
        tfArea.text = currentNews.area
        
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnAddImagePressed(_ sender: Any) {
        
        
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }

    @IBAction func btnSavePressed(_ sender: Any) {
        
        
    }
    

}
