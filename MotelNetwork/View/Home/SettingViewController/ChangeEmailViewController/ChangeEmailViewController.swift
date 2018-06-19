//
//  ChangeEmailViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/9/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher

class ChangeEmailViewController: UIViewController {

    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnBackToAccountDetail: UIButton!
    @IBOutlet weak var btnSaveEmail: UIButton!
    @IBOutlet weak var tfNewEmail: UITextField!
    
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
    
    
    //MARK: Handle button pressed
    
    @IBAction func btnBackToAccountDetail(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveEmailPressed(_ sender: Any) {
        
        let newEmail = tfNewEmail.text
        
        if (tfNewEmail.text?.isEmpty)! {
            
            showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
        }
        else if !isValidEmail(email: newEmail!) {
            
            showAlert(title: "Thông báo", alertMessage: messageInvalidEmail)
        }
        else {
            
            Auth.auth().addStateDidChangeListener({ (auth, user) in
                
                if user != nil {
                    self.showAlertConfirmChangeEmail(newEmail: newEmail!)
                    self.tfNewEmail.text = ""
                }
                else {
                }
            })
        }
        
        return
    }
}
