//
//  ChangePasswordViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/8/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher

class ChangePasswordViewController: UIViewController {
    
    
    @IBOutlet weak var tfPasswordConfirm: UITextField!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnBackToAccountDetail: UIButton!
    @IBOutlet weak var btnSavePassword: UIButton!
    @IBOutlet weak var tfNewPassword: UITextField!
    
    var dbReference: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set up vier
    
    func setUpView() {
        
        self.tapToDismissKeyboard()
        
        let uid = Auth.auth().currentUser?.uid
        
        dbReference = Database.database().reference()
        dbReference.child("Users").child(uid!).observe(.value) { (snapshot) in
            
            // Get user value
            let value = snapshot.value as! NSDictionary
            let userName = value["FullName"] as? String ?? ""
            let profileImageUrl = value["ProfileImageUrl"] as? String ?? ""
            let email = value["Email"] as? String ?? ""
            
            self.lblFullName.text = userName
            self.lblEmail.text = email
            self.loadImageToImageView(imageUrl: profileImageUrl, imageView: self.ivAvatar)
        }
        
        makeImageViewRounded(imageView: ivAvatar)        
    }
    
    
    @IBAction func btnBackToAccountDetail(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSavePasswordPressed(_ sender: Any) {
        
        let newPass = tfNewPassword.text!
        let newPassConfirm = tfPasswordConfirm.text!
        
        if (tfNewPassword.text?.isEmpty)! || (tfPasswordConfirm.text?.isEmpty)! {
            
            showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
        }
        else if newPass.count < 6 {
            
            showAlert(title: "Thông báo", alertMessage: messagePasswordLessThan6Chars)
        }
        else if newPass.elementsEqual(newPassConfirm) == false  {
            
            showAlert(title: "Thông báo", alertMessage: messageWrongPasswordConfirm)
        }
        else {
            Auth.auth().addStateDidChangeListener({ (auth, user) in
                
                if user != nil {
                    
                    self.showAlertConfirmChangePassword(newPass: newPass)
                    self.tfNewPassword.text = ""
                    self.tfPasswordConfirm.text = ""
                }
                else {
                }
            })
        }
        
        
        return
    }
}
