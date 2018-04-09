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

extension UIViewController {
    
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
