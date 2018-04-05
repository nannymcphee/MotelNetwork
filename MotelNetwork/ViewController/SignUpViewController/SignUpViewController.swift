//
//  SignUpViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 3/25/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class UserType {
    var userType: Int
    var userTypeName: String
    
    init(userType: Int, userTypeName: String) {
        self.userType = userType
        self.userTypeName = userTypeName
    }
}

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnExit: UIButton!
    @IBOutlet weak var pvUserType: UIPickerView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfCMND: UITextField!
    @IBOutlet weak var tfBirthDay: UITextField!
    
    
    var userType = [UserType]()
    var ref: DatabaseReference!
    let dpBirthDay = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        
        ref = Database.database().reference()
        
        pvUserType.delegate = self
        pvUserType.dataSource = self
        
        userType.append(UserType(userType: 0, userTypeName: "Chủ nhà trọ"))
        userType.append(UserType(userType: 1, userTypeName: "Khách thuê trọ"))
        
        btnRegister.layer.cornerRadius = 15

        // Do any additional setup after loading the view.
    }
    
    // Create Date Picker
    func createDatePicker() {
        dpBirthDay.locale = NSLocale.init(localeIdentifier: "vi_VN") as Locale
        // Add toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Add "Done" button
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(btnDonePressed))
        toolbar.setItems([btnDone], animated: false)
        
        tfBirthDay.inputAccessoryView = toolbar
        tfBirthDay.inputView = dpBirthDay
        
        // Format picker view for date
        dpBirthDay.datePickerMode = .date
    }
    
    // btnDonePressed event for Date Picker
    @objc func btnDonePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateFormatter.locale = NSLocale.init(localeIdentifier: "vi_VN") as Locale
        tfBirthDay.text = dateFormatter.string(from: dpBirthDay.date)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return userType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
        return userType[row].userTypeName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadComponent(0)
        
        let selectedUserType = pvUserType.selectedRow(inComponent: 0)
//        let userType2 = userType[selectedUserType].userType
    }
    
    @IBAction func btnExitPressed(_ sender: Any) {
        
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnRegisterPressed(_ sender: UIButton) {
        
        // Sign up user with Email & Password
        let email = tfEmail.text, pass = tfPassword.text
        Auth.auth().createUser(withEmail: email!, password: pass!) { (user, error) in
            if error != nil {
                print(error)
                return
            }
            
            let userID: String = (user?.uid)!
            let userEmail: String = self.tfEmail.text!
            let userPassword: String = self.tfPassword.text!
            let userFullName: String = self.tfName.text!
            let userCMND: String = self.tfCMND.text!
            let userBirthDay = self.tfBirthDay.text!
            let userType = self.pvUserType.selectedRow(inComponent: 0)
            
            // Add user's information to database
            self.ref.child("Users").child(userID).setValue(["FullName": userFullName, "Email": userEmail, "Password": userPassword, "CMND": userCMND, "BirthDay": userBirthDay, "UserType": userType])
            
            // Create UIAlertView
            let avRegisterSuccess: UIAlertView = UIAlertView(title: "Thông báo", message: "Đăng ký thành công!", delegate: self, cancelButtonTitle: "OK")
            avRegisterSuccess.show()
            
            let vc = LoginViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
