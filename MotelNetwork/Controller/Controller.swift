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
import NVActivityIndicatorView
import Kingfisher

var activityIndicatorView : NVActivityIndicatorView!
var blurEffectView : UIVisualEffectView!
let numberFormatter = NumberFormatter()

extension UIViewController {
    
    // MARK: Handle login
    
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
                    self.showAlert(alertMessage: messageLoginFailed)
                    return
                }
            }
        }
    }
    
    //MARK: Handle log out
    
    func doLogOut() {
        
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Make button and ImageView rounded
    
    func makeButtonRounded(button: UIButton) {
        button.layer.cornerRadius = button.frame.height / 2.0
        button.clipsToBounds = true
    }
    
    func makeImageViewRounded(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.width / 2.0
        imageView.clipsToBounds = true
    }
    
    //MARK: Show alerts
    
    func showAlert(alertMessage: String) {
        let alert = UIAlertController(title: "Thông báo", message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertNavigateToDetailBill() {
        let alert = UIAlertController(title: "Lưu thông tin thành công.", message: "Bạn có muốn xem chi tiết hóa đơn không?", preferredStyle: .alert)
        let actionDestroy = UIAlertAction(title: "Có", style: .destructive) { (action) in
            let vc = DetailBillViewController()
            
            (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
        }
        
        let actionCancel = UIAlertAction(title: "Không", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(actionDestroy)
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertConfirmLogOut() {
        
        let alert = UIAlertController(title: messageConfirmLogOut, message: nil, preferredStyle: .actionSheet)
        let actionDestroy = UIAlertAction(title: "Đăng xuất", style: .destructive) { (action) in
            self.doLogOut()
        }
        
        let actionCancel = UIAlertAction(title: "Không", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(actionDestroy)
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertConfirmChangePassword(newPass: String) {

        let alert = UIAlertController(title: "Thông báo", message: messageConfirmChangePassword, preferredStyle: .alert)
        let actionDestroy = UIAlertAction(title: "Có", style: .destructive) { (action) in
            self.doChangePassword(newPass: newPass)
        }
        let actionCancel = UIAlertAction(title: "Không", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }

        alert.addAction(actionDestroy)
        alert.addAction(actionCancel)

        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertConfirmChangeEmail(newEmail: String) {
        
        let alert = UIAlertController(title: "Thông báo", message: messageConfirmChangeEmail, preferredStyle: .alert)
        let actionDestroy = UIAlertAction(title: "Có", style: .destructive) { (action) in
            self.doChangeEmail(newEmail: newEmail)
        }
        let actionCancel = UIAlertAction(title: "Không", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(actionDestroy)
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Change password & email
    
    func doChangePassword(newPass: String) {
        
        if let user = Auth.auth().currentUser {
            
            user.updatePassword(to: newPass, completion: { (error) in
                
                if let error = error {
                    
                    print(error)
                    self.showAlert(alertMessage: messageRequestLogOut)
                }
                else {
                    
                    let uid = Auth.auth().currentUser?.uid
                    let values = ["Password": newPass]
                    let ref = Database.database().reference().child("Users").child(uid!)
                    self.storeInformationToDatabase(reference: ref, values: values as [String: AnyObject])
                    DispatchQueue.main.async {
                        self.showAlert(alertMessage: messageChangePasswordSuccess)
                    }
                }
            })
        }
    }
    
    func doChangeEmail(newEmail: String) {
        
        if let user = Auth.auth().currentUser {
            
            user.updateEmail(to: newEmail) { (error) in
                
                if let error = error {
                    
                    print(error)
                    self.showAlert(alertMessage: messageRequestLogOut)
                }
                else {
                    
                    let uid = Auth.auth().currentUser?.uid
                    let values = ["Email": newEmail]
                    let ref = Database.database().reference().child("Users").child(uid!)
                    self.storeInformationToDatabase(reference: ref, values: values as [String: AnyObject])
                    DispatchQueue.main.async {
                        self.showAlert(alertMessage: messageChangeEmailSuccess)
                    }
                }
            }
        }
    }
    
    //MARK: Check if email is valid
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with:email)
    }
    
    //MARK: Database interactions
    
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
    
    // Store to database
    func storeInformationToDatabase(reference: DatabaseReference, values: [String: AnyObject]) {
    
        reference.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                
                print(error!)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // Delete data from database
    func deleteData(reference: DatabaseReference) {
        
        reference.removeValue { (error, ref) in
            if let error = error {
                print(error)
            }
        }
    }
    
    // Edit data
    func editData(reference: DatabaseReference, newValues: [String: AnyObject]) {
        
        reference.updateChildValues(newValues) { (error, ref) in
            
            if let error = error {
                
                print(error)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }

    //MARK: Tap anywhere to dismiss keyboard
    
    func tapToDismissKeyboard() {

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: Check auth status and handle log out
    
    func checkAuthStatus() {
        
        if Auth.auth().currentUser?.uid == nil {
            
            performSelector(onMainThread: #selector(handleLogout), with: nil, waitUntilDone: true)
        }
        else {
            
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("Users").child(uid!).child("FullName").observeSingleEvent(of: .value, with: { (snapshot) in
                
                print("User logged in as \(snapshot)")
            }, withCancel: nil)
        }
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Load image to image view using Kingfisher
    
    func loadImageToImageView(imageUrl: String, imageView: UIImageView) {
        
        if URL(string: imageUrl) != nil {
            let resource = ImageResource(downloadURL: URL(string: imageUrl)!)
            
            imageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "defaultImage") , options: nil, progressBlock: nil, completionHandler: nil)
        }
        else{
            imageView.image = #imageLiteral(resourceName: "defaultImage")
        }
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

extension UITableView {
    
    func scrollTableViewToBottom(animated: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
        }
    }
    
    func scrollTableViewToTop(animated: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
        }
    }
}


