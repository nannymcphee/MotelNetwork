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
import FirebaseStorage
import NVActivityIndicatorView
import Kingfisher

var activityIndicatorView : NVActivityIndicatorView!
var blurEffectView : UIVisualEffectView!
let numberFormatter = NumberFormatter()

extension UIViewController {
    
    // MARK: Handle login
    
    func doLogin(email: String, pass: String) {
        showLoading()
        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            if user != nil {
                self.stopLoading()
                let vc = MainViewController()
                (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
            }
            else {
                
                if let firebaseError = error {
                    
                    print(firebaseError)
                    self.showAlert(title: "Thông báo", alertMessage: messageLoginFailed)
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
    
    func showAlert(title: String, alertMessage: String) {
        let alert = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
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
                    
                    self.showAlert(title: "Thông báo", alertMessage: messageRequestLogOut)
                }
                else {
                    
                    let uid = Auth.auth().currentUser?.uid
                    let values = ["Password": newPass]
                    let ref = Database.database().reference().child("Users").child(uid!)
                    self.storeInformationToDatabase(reference: ref, values: values as [String: AnyObject])
                    NativePopup.show(image: Preset.Feedback.done, title: messageChangePasswordSuccess, message: nil, duration: 1.5, initialEffectType: .fadeIn)
                }
            })
        }
    }
    
    func doChangeEmail(newEmail: String) {
        
        if let user = Auth.auth().currentUser {
            
            user.updateEmail(to: newEmail) { (error) in
                
                if let error = error {
                    
                    print(error)
                    self.showAlert(title: "Thông báo", alertMessage: messageRequestLogOut)
                }
                else {
                    
                    let uid = Auth.auth().currentUser?.uid
                    let values = ["Email": newEmail]
                    let ref = Database.database().reference().child("Users").child(uid!)
                    self.storeInformationToDatabase(reference: ref, values: values as [String: AnyObject])
                    NativePopup.show(image: Preset.Feedback.done, title: messageChangeEmailSuccess, message: nil, duration: 1.5, initialEffectType: .fadeIn)
                }
            }
        }
    }
    
    //MARK: Check if email is valid
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: email)
    }
    
    //MARK: Check if address is valid
    
//    func isValidAddress(address: String) -> Bool {
//        let addressRegEx = "(?i)([0-9A-ZẮẰẲẴẶĂẤẦẨẪẬÂÁÀÃẢẠĐẾỀỂỄỆÊÉÈẺẼẸÍÌỈĨỊỐỒỔỖỘÔỚỜỞỠỢƠÓÒÕỎỌỨỪỬỮỰƯÚÙỦŨỤÝỲỶỸỴ']+\\s?\\b){2,}"
////        let addressTest = NSPredicate(format:"SELF MATCHES %@", addressRegEx)
//        return addressRegEx.range(of: "(?i)([0-9A-ZẮẰẲẴẶĂẤẦẨẪẬÂÁÀÃẢẠĐẾỀỂỄỆÊÉÈẺẼẸÍÌỈĨỊỐỒỔỖỘÔỚỜỞỠỢƠÓÒÕỎỌỨỪỬỮỰƯÚÙỦŨỤÝỲỶỸỴ']+\\s?\\b){2,}", options: .regularExpression) != nil
//    }
    
    //MARK: Check if phone number is valid 
    
//    func isValidPhoneNumber(phoneNumber: String) -> Bool {
//        let phoneNumberRegEx = "/^(01[2689]|09)[0-9]{8}$/"
//        let phoneNumberTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegEx)
//
//        return phoneNumberTest.evaluate(with: phoneNumber)
//    }
    
    //MARK: Database interactions
    
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
    
    // Delete data from database
    func deleteData(reference: DatabaseReference) {
        
        reference.removeValue { (error, ref) in
            if let error = error {
                print(error)
            }
        }
    }
    
    // Delete data from storage
    func deleteFromStorage(storageRef: StorageReference) {
        storageRef.delete { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    // Increase view
    func increaseViewForPost(reference: DatabaseReference) {
        
        reference.runTransactionBlock { (currentData: MutableData!) -> TransactionResult in
            var value = currentData.value as? Int
            
            if value == nil {
                value = 0
            }
            
            currentData.value = value! + 1
            
            return TransactionResult.success(withValue: currentData)
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


