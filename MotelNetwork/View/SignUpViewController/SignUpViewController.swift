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
import BSImagePicker
import Photos
import SwipeBack

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
    @IBOutlet weak var ivProfilePicture: UIImageView!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    
    var userType = [UserType]()
    var imageArray = [UIImage]()
    var selectedAssets = [PHAsset]()
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
        let btnDone = UIBarButtonItem(title: "Xong", style: .done, target: nil, action: #selector(btnDonePressed))
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
        userType.append(UserType(userType: 0, userTypeName: "Chủ nhà trọ"))
        userType.append(UserType(userType: 1, userTypeName: "Khách thuê trọ"))
        makeButtonRounded(button: btnProfilePicture)
        ivProfilePicture.isHidden = true
        self.tapToDismissKeyboard()
        btnProfilePicture.imageView?.contentMode = .scaleAspectFit
    }
    
    func resetView() {
        ivProfilePicture.image = nil
        tfCMND.text = ""
        tfName.text = ""
        tfEmail.text = ""
        tfBirthDay.text = ""
        tfPassword.text = ""
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
    }
    
    //MARK: Database interaction
    
    // Upload image from UIImageView to storage and return download url
    func uploadImageFromImageView(imageView : UIImageView, completion: @escaping ((String) -> (Void))) {
        
        var strURL = ""
        let imageName = NSUUID().uuidString
        let uid = Auth.auth().currentUser?.uid
        let storageRef = Storage.storage().reference().child("ProfileImages").child(uid!).child("\(imageName).png")
        let storeImage = storageRef
        
        if let uploadImageData = UIImageJPEGRepresentation(imageView.image!, 0.2) {
            
            storeImage.putData(uploadImageData, metadata: nil, completion: { (metaData, error) in
                storeImage.downloadURL(completion: { (url, error) in
                    if let urlText = url?.absoluteString {
                        
                        strURL = urlText
                        print("///////////tttttttt//////// \(strURL)   ////////")
                        
                        completion(strURL)
                    }
                })
            })
        }
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnExitPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnProfilePicturePressed(_ sender: Any) {
        
        imageArray.removeAll()
        selectedAssets.removeAll()
        
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 1
        vc.cancelButton.title = "Đóng"
        vc.doneButton.title = "Xong"
        self.bs_presentImagePickerController(vc, animated: true, select: { (asset: PHAsset) in
        }, deselect: { (asset: PHAsset) in
            
        }, cancel: { (asset: [PHAsset]) in
            
        }, finish: { (asset: [PHAsset]) in
            
            if asset.count < 1 {
                self.showAlert(title: "Thông báo", alertMessage: "Vui lòng chọn 1 hình.")
            }
            else {
                for i in 0..<asset.count {
                    self.selectedAssets.append(asset[i])
                }
                
                self.convertAssetToImages()
                
                return
            }
        }, completion: nil)
    }
    
    @IBAction func btnRegisterPressed(_ sender: UIButton) {
        
        let userEmail: String = self.tfEmail.text!
        let userPassword: String = self.tfPassword.text!
        let userFullName: String = self.tfName.text!
        let userCMND: String = self.tfCMND.text!
        let userBirthDay = self.tfBirthDay.text!
        let userPhoneNumber = self.tfPhoneNumber.text!
        let userType = self.pvUserType.selectedRow(inComponent: 0)
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        // Check if user has entered all informations
        if userFullName.isEmpty || userEmail.isEmpty || userPassword.isEmpty || userCMND.isEmpty || userBirthDay.isEmpty || userPhoneNumber.isEmpty {
            
            showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
        }
        else if ivProfilePicture.image == nil {
            
            showAlert(title: "Thông báo", alertMessage: messageNilImages)
        }
        else if userPassword.count < 6 {
            
            showAlert(title: "Thông báo", alertMessage: messagePasswordLessThan6Chars)
        }
        else if !isValidEmail(email: userEmail) {
            
            showAlert(title: "Thông báo", alertMessage: messageInvalidEmail)
        }
        else {
            
            // Sign up user with Email & Password
            
            Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (user, error) in
                
                if let error = error {
                    
                    print(error)
                    self.showAlert(title: "Thông báo", alertMessage: messageEmailAlreadyUsed)
                    return
                }
                else {
                    
//                    do {
//                        try Auth.auth().signOut()
//                    } catch let error {
//                        print(error)
//                    }
                    
//                    Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
//                        if let error = error {
//                            print(error)
//                        }
//                        else  {
//                            
//                            self.showAlert(alertMessage: "Vui lòng kiểm tra email của bạn để kích hoạt tài khoản.")
//                        }
//                    })
                    
                    guard let uid = user?.uid else {
                        
                        return
                    }
                    
                    let reference = Database.database().reference().child("Users").child(uid)
                    
                    // Store user's info to database
                    
                    let values = ["FullName": userFullName, "Email": userEmail, "Password": userPassword, "CMND": userCMND, "BirthDay": userBirthDay, "UserType": userType, "ProfileImageUrl": "", "PhoneNumber": userPhoneNumber, "TimeStamp": timestamp] as [String : AnyObject]
                    
                    self.storeInformationToDatabase(reference: reference, values: values as [String : AnyObject])
                    
                    // Upload image to Firebase storage and update download url into database
                    
                    _ = self.uploadImageFromImageView(imageView: self.ivProfilePicture) { (url) in
                        self.storeInformationToDatabase(reference: reference, values: ["ProfileImageUrl": url as AnyObject])
                    }

                    self.showLoading()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                        self.stopLoading()
                        self.noticeSuccess(messageSignUpSuccess, autoClear: true, autoClearTime: 1)
                        self.resetView()
                    })
                }
            }
            return
        }
    }
    
    //Mark: Convert selected assets to image
    
    func convertAssetToImages() -> Void {
        
        if selectedAssets.count != 0 {
            
            for i in 0..<selectedAssets.count {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: selectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option) { (result, info) in
                    thumbnail = result!
                }
                
                let data = UIImageJPEGRepresentation(thumbnail, 0.2)
                let newImage = UIImage(data: data!)
                
                self.imageArray.append((newImage as UIImage?)!)
            }
            
            DispatchQueue.main.async {
                self.ivProfilePicture.image = self.imageArray[0]
                self.btnProfilePicture.setImage(self.imageArray[0], for: .normal)
            }
        }
    }

}


