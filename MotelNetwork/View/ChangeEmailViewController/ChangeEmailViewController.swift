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
        
        showLoading()
        
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
            self.ivAvatar.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        makeImageViewRounded(imageView: ivAvatar)
        makeButtonRounded(button: btnSaveEmail)
        
        stopLoading()
    }
    
    
    //MARK: Handle button pressed
    
    @IBAction func btnBackToAccountDetail(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveEmailPressed(_ sender: Any) {
        
        let newEmail = tfNewEmail.text
        
        if newEmail == "" {
            
            showAlert(alertMessage: messageNilTextFields)
        }
        else if !isValidEmail(email: newEmail!) {
            
            showAlert(alertMessage: messageInvalidEmail)
        }
        else {
            
            _ = Auth.auth().addStateDidChangeListener { (auth, user) in

                if user != nil {

                    //User is signed in
                    self.showAlert(alertMessage: messageRequestReLogin)
                }
                else {
                    if let user = Auth.auth().currentUser {

                        user.updateEmail(to: newEmail!) { (error) in

                            if let error = error {

                                print(error.localizedDescription)
                                self.showAlert(alertMessage: messageChangeEmailFailed)
                            }
                            else {

                                // Update database
                                let uid = Auth.auth().currentUser?.uid
                                let values = ["Email": newEmail]

                                self.storeUserInformationToDatabase(uid!, values: values as [String : AnyObject])
                                self.showAlert(alertMessage: messageChangeEmailSuccess)
                            }
                        }
                    }
                }
            }
        }
    }
}
