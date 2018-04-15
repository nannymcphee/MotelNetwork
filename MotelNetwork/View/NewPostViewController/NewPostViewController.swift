//
//  NewPostViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/10/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Photos
import BSImagePicker

class NewPostViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var btnClearTextView: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var ivPostImage0: UIImageView!
    @IBOutlet weak var ivPostImage1: UIImageView!
    @IBOutlet weak var ivPostImage2: UIImageView!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfDistrict: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfElectricPrice: UITextField!
    @IBOutlet weak var tfWaterPrice: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var tfInternetPrice: UITextField!
    @IBOutlet weak var tfArea: UITextField!
    

    var selectedAssets = [PHAsset]()
    var imageArray = [UIImage]()
    var userName: String = ""
    var userProfileImageUrl: String = ""
    var currentDate: String = ""
    var dbReference: DatabaseReference!
    let pvDistrict = UIPickerView()
    let postID = UUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pvDistrict.delegate = self
        pvDistrict.dataSource = self
        
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set up view
    
    func setUpView() {
        
        checkAuthStatus()
        getCurrentUser()
        getCurrentDate()
        createDistrictListPicker()
        self.tapToDismissKeyboard()
        makeButtonRounded(button: btnClearTextView)
    }
    
    func getCurrentDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let str = formatter.string(from: Date())
        currentDate = str
    }
    
    //MARK: Reset view
    
    func resetView() {
        
        self.ivPostImage0.image = nil
        self.ivPostImage1.image = nil
        self.ivPostImage2.image = nil
        self.tfArea.text = ""
        self.tfDistrict.text = ""
        self.tfPrice.text = ""
        self.tfTitle.text = ""
        self.tfAddress.text = ""
        self.tfInternetPrice.text = ""
        self.tfElectricPrice.text = ""
        self.tfWaterPrice.text = ""
        self.tfPhoneNumber.text = ""
        self.tvDescription.text = ""
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
                self.imageArray.append(newImage as! UIImage)
            }
            self.ivPostImage0.image = imageArray[0]
            self.ivPostImage1.image = imageArray[1]
            self.ivPostImage2.image = imageArray[2]
        }
    }
    
    //MARK: Database interaction
    
    // Fetch user from database
    func getCurrentUser() {
        
        let uid = Auth.auth().currentUser?.uid
        
        dbReference = Database.database().reference()
        dbReference.child("Users").child(uid!).observe(.value) { (snapshot) in
            
            // Get user value
            let value = snapshot.value as! NSDictionary
            let name = value["FullName"] as? String ?? ""
            let profileImageUrl = value["ProfileImageUrl"] as? String ?? ""
            
            self.userName = name
            self.userProfileImageUrl = profileImageUrl
        }
    }
    
    // Store room's info to database
    private func storePostInformationToDatabase(_ uid: String, values: [String: AnyObject]) {
        
        // Create database references
        let dbRef = Database.database().reference()
        let postRef = dbRef.child("Posts").child(uid).child("MyPosts").child("\(postID)")
        
        postRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                
                print(error!)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // Upload image from UIImageView to storage and return download url
    func uploadImageFromImageView(imageView : UIImageView, completion: @escaping ((String) -> (Void))) {
        
        var strURL = ""
        let uid = Auth.auth().currentUser?.uid
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("PostImages").child(uid!).child("\(imageName).jpg")
        let storeImage = storageRef
        
        if let uploadImageData = UIImageJPEGRepresentation(imageView.image!, 0.7) {
            
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
    
    
    //MARK: Logic for tfDistrict
    
    func createDistrictListPicker() {
        
        // Add toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Add "Done" button
        let btnDone = UIBarButtonItem(title: "Xong", style: .done, target: nil, action: #selector(btnDonePressed))
        toolbar.setItems([btnDone], animated: false)
        
        self.tfDistrict.inputView = self.pvDistrict
        self.tfDistrict.inputAccessoryView = toolbar
    }
    
    @objc func btnDonePressed() {
        self.view.endEditing(false)
    }
    
    //MARK: Logic for UIPickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return districtList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return districtList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        pickerView.reloadComponent(0)
        tfDistrict.text = districtList[row]
    }
    
    
    
    //MARK: Handle button pressed

    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnClearTextViewPressed(_ sender: Any) {
        
        tvDescription.text = ""
    }
    
    
    @IBAction func btnAddImagePressed(_ sender: Any) {
        
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 3
        self.bs_presentImagePickerController(vc, animated: true, select: { (asset: PHAsset) in
            
        }, deselect: { (asset: PHAsset) in
            
        }, cancel: { (asset: [PHAsset]) in
            
        }, finish: { (asset: [PHAsset]) in
            
            for i in 0..<asset.count {
                self.selectedAssets.append(asset[i])
            }
            
            self.convertAssetToImages()
        }, completion: nil)
    }
    
    @IBAction func btnSavePressed(_ sender: Any) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        if tfDistrict.text == nil || tfTitle.text == nil || tfArea.text == nil || tfPrice.text == nil || tfAddress.text == nil || tfWaterPrice.text == nil || tfPhoneNumber.text == nil || tfElectricPrice.text == nil || tfInternetPrice.text == nil || tvDescription.text == nil || ivPostImage0.image == nil || ivPostImage1.image == nil || ivPostImage2.image == nil {
            
            showAlert(alertMessage: messageNilTextFields)
        }
        else if (tfTitle.text?.count)! > 50 || (tfAddress.text?.count)! > 50 {
            
            showAlert(alertMessage: messageLimitCharacters)
        }
        else {
        
            // Store post's info to database
            let title = self.tfTitle.text!
            let area = self.tfArea.text!
            let district = self.tfDistrict.text!
            let address = self.tfAddress.text!
            let waterPrice = self.tfWaterPrice.text!
            let phoneNumber = self.tfPhoneNumber.text!
            let electricPrice = self.tfElectricPrice.text!
            let price = self.tfPrice.text!
            let description = self.tvDescription.text!
            let internetPrice = self.tfInternetPrice.text!
            let postDate = currentDate
           
            let values = ["title": title, "description": description, "address": address, "district": district, "price": price, "electricPrice": electricPrice, "waterPrice": waterPrice, "internetPrice": internetPrice, "area": area, "phoneNumber": phoneNumber, "postImageUrl0": "", "postImageUrl1": "", "postImageUrl2": "", "user": userName, "userProfileImageUrl": userProfileImageUrl, "postDate": postDate]
            
            self.storePostInformationToDatabase(uid, values: values as [String: AnyObject])
            
            // Upload image to Firebase storage and update download urls into database
            
            _ = uploadImageFromImageView(imageView: ivPostImage0) { (url) in
                self.storePostInformationToDatabase(uid, values: ["postImageUrl0": url as AnyObject])
            }
            
            _ = uploadImageFromImageView(imageView: ivPostImage1) { (url) in
                self.storePostInformationToDatabase(uid, values: ["postImageUrl1": url as AnyObject])
            }
            
            _ = uploadImageFromImageView(imageView: ivPostImage2) { (url) in
                self.storePostInformationToDatabase(uid, values: ["postImageUrl2": url as AnyObject])
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.showAlert(alertMessage: messageNewPostSuccess)
            })
            
            resetView()
        }
        
        return
    }
    
}
