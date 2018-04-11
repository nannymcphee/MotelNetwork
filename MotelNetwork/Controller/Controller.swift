//
//  Controller.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/9/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

extension UIViewController {
    
    // Handle login
    func doLogin(email: String, pass: String) {
        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            
            if let u = user {
                
                print(u)
                let vc = MainViewController()
                (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
            }
            else {
                
                if let firebaseError = error {
                    
                    print(firebaseError)
                    return
                }
            }
        }
    }
    
    // Handle log out
    func doLogOut() {
        
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func makeButtonRounded(button: UIButton) {
        button.layer.cornerRadius = button.frame.height / 2.0
        button.clipsToBounds = true
    }
    
    func makeImageViewRounded(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.width / 2.0
        imageView.clipsToBounds = true
    }
    
    func showAlert(alertMessage: String) {
        let alert = UIAlertController(title: "Thông báo", message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with:email)
    }
    
    // Update user's information to database
    func storeUserInformationToDatabase(_ uid: String, values: [String: AnyObject]) {
        
        // Add user's information to database
        let databaseRef = Database.database().reference()
        let usersRef = databaseRef.child("Users").child(uid)
        
        usersRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                
                print(error!)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tapToDismissKeyboard(view: UIView) {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(dismissKeyboard))
        
//        Uncomment the line below if you want the tap not not interfere and cancel other interactions.
//        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension UISearchBar {
    
    func changeTextFont(textFont: UIFont?) {
        for view: UIView in (self.subviews[0]).subviews {
            if let textField = view as? UITextField {
                textField.font = textFont
            }
        }
    }
}
