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
import FirebaseStorage

class UserType {
    var userType: Int
    var userTypeName: String
    
    init(userType: Int, userTypeName: String) {
        self.userType = userType
        self.userTypeName = userTypeName
    }
}

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    
    @IBOutlet weak var btnProfilePicture: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnExit: UIButton!
    @IBOutlet weak var pvUserType: UIPickerView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfCMND: UITextField!
    @IBOutlet weak var tfBirthDay: UITextField!
    
    
    var userType = [UserType]()
    let dpBirthDay = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pvUserType.delegate = self
        pvUserType.dataSource = self
        
        setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Create & handle date picker
    
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


    
    //MARK: Set up view
    func setUpView() {
        createDatePicker()
        makeButtonRounded(button: btnRegister)
        userType.append(UserType(userType: 0, userTypeName: "Chủ nhà trọ"))
        userType.append(UserType(userType: 1, userTypeName: "Khách thuê trọ"))
    }
    
    //MARK: Logic for pvUser
    
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
        print(selectedUserType)
//        let userType2 = userType[selectedUserType].userType
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnExitPressed(_ sender: Any) {
        
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnProfilePicturePressed(_ sender: Any) {
        handleSelectProfilePicturePressed()
    }
    
    @IBAction func btnRegisterPressed(_ sender: UIButton) {
        
        // Check if user has entered all informations
        if tfName.text == "" || tfEmail.text == "" || tfPassword.text == "" || tfCMND.text == "" || tfBirthDay.text == "" {
            
            showAlert(alertMessage: messageNilTextFields)
        }
        else {
            
            // Sign up user with Email & Password
            let email = tfEmail.text, pass = tfPassword.text
            Auth.auth().createUser(withEmail: email!, password: pass!) { (user, error) in
                
                if let error = error {
                    
                    print(error)
                    return
                }
                
                guard let uid = user?.uid else {
                    
                    return
                }
                
                // Succesfully signed up user
                let imageName = UUID().uuidString
                let storageRef = Storage.storage().reference().child("ProfileImages").child("\(imageName).png")
                
                if let profileImage = self.btnProfilePicture.image(for: .normal), let uploadData = UIImagePNGRepresentation(profileImage) {
                    
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                            
                            let userEmail: String = self.tfEmail.text!
                            let userPassword: String = self.tfPassword.text!
                            let userFullName: String = self.tfName.text!
                            let userCMND: String = self.tfCMND.text!
                            let userBirthDay = self.tfBirthDay.text!
                            let userType = self.pvUserType.selectedRow(inComponent: 0)
                            
                            let values = ["FullName": userFullName, "Email": userEmail, "Password": userPassword, "CMND": userCMND, "BirthDay": userBirthDay, "UserType": userType, "ProfileImageUrl": profileImageUrl] as [String : Any]
                            
                            self.storeUserInformationToDatabase(uid, values: values as [String : AnyObject])
                        }
                    })
                }

                self.showAlert(alertMessage: messageSignUpSuccess)
            }
        }
    }
    
    //MARK: Database interaction
    
    private func storeUserInformationToDatabase(_ uid: String, values: [String: AnyObject]) {
        
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
    
    //MARK: Logic for btnProfilePicture
    
    func handleSelectProfilePicturePressed() {
        
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var  selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            btnProfilePicture.setImage(selectedImage, for: .normal)
            btnProfilePicture.layer.cornerRadius = btnProfilePicture.frame.size.width / 2
            btnProfilePicture.clipsToBounds = true
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
        print("Canceled")
    }

}
