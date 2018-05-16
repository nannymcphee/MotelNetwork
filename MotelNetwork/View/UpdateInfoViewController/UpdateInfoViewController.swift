//
//  UpdateInfoViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/26/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import BSImagePicker
import Photos
import Kingfisher

class UpdateInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var tfUserName: UITextField!
    
    @IBOutlet weak var tfCMND: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var tfBirthDay: UITextField!
    @IBOutlet weak var ivProfileImage: UIImageView!
    
    let uid = Auth.auth().currentUser?.uid
    var profileImageUrl: String?
    var imageArray = [UIImage]()
    var selectedAssets = [PHAsset]()
    let dpBirthDay = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set up view
    
    func setUpView() {
        
        let ref = Database.database().reference().child("Users").child(uid!)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.profileImageUrl = dictionary["ProfileImageUrl"] as? String
                self.tfUserName.text = dictionary["FullName"] as? String
                self.tfBirthDay.text = dictionary["BirthDay"] as? String
                self.tfCMND.text = dictionary["CMND"] as? String
                self.tfPhoneNumber.text = dictionary["PhoneNumber"] as? String
                let resouce = ImageResource(downloadURL: URL(string: self.profileImageUrl!)!)
                self.ivProfileImage.kf.setImage(with: resouce, placeholder: #imageLiteral(resourceName: "defaultAvatar"), options: nil, progressBlock: nil, completionHandler: nil)
                self.btnAddImage.setImage(self.ivProfileImage.image, for: .normal)
            }
        }, withCancel: nil)
        
        self.tapToDismissKeyboard()
        createDatePicker()
        makeButtonRounded(button: btnAddImage)
        self.btnAddImage.imageView?.contentMode = .scaleAspectFit
        self.ivProfileImage.isHidden = true
    }
    
    //MARK: Database interactions
    
    // Upload image from UIImageView to storage and return download url
    func uploadImageFromImageView(imageView : UIImageView, completion: @escaping ((String) -> (Void))) {
        
        var strURL = ""
        let uid = Auth.auth().currentUser?.uid
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("ProfileImages").child(uid!).child("\(imageName).jpg")
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
                
                let data = UIImageJPEGRepresentation(thumbnail, 0.7)
                let newImage = UIImage(data: data!)
                
                self.imageArray.append((newImage as UIImage?)!)
            }
            
            DispatchQueue.main.async {
                self.ivProfileImage.image = self.imageArray[0]
                self.btnAddImage.setImage(self.imageArray[0], for: .normal)

            }
        }
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddImagePressed(_ sender: Any) {
        
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
    
    @IBAction func btnSavePressed(_ sender: Any) {
        
        if (tfUserName.text?.isEmpty)! || (tfPhoneNumber.text?.isEmpty)! || (tfCMND.text?.isEmpty)! || (tfBirthDay.text?.isEmpty)! {
            
            self.showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
        }
        else {
            
            let userName = self.tfUserName.text!
            let phoneNumber = self.tfPhoneNumber.text!
            let cmnd = self.tfCMND.text!
            let birthDay = self.tfBirthDay.text!
            let values = ["FullName": userName, "ProfileImageUrl": self.profileImageUrl, "PhoneNumber": phoneNumber, "CMND": cmnd, "BirthDay": birthDay]
            let ref = Database.database().reference().child("Users").child(uid!)

            // Create confirm alert
            let alert = UIAlertController(title: "Thông báo", message: messageConfirmEditData, preferredStyle: .alert)
            let actionDestroy = UIAlertAction(title: "Có", style: .destructive) { (action) in
                
                if (self.tfUserName.text?.isEmpty)! {
                    
                    self.showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
                }
                else if self.ivProfileImage.image == nil {
                    
                    self.editData(reference: ref, newValues: values as [String: AnyObject])
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                        self.noticeSuccess(messageEditInfoSuccess, autoClear: true, autoClearTime: 1)
                    })
                }
                else {
                    
                    self.editData(reference: ref, newValues: values as [String: AnyObject])
                    
                    // Upload image to Firebase storage and update download urls into database
                    
                    _ = self.uploadImageFromImageView(imageView: self.ivProfileImage) { (url) in
                        self.editData(reference: ref, newValues: ["ProfileImageUrl": url as AnyObject])
                    }
                }
                
                self.noticeSuccess(messageEditInfoSuccess, autoClear: true, autoClearTime: 1)
                
                return
            }
            
            let actionCancel = UIAlertAction(title: "Không", style: .cancel) { (action) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                    alert.dismiss(animated: true, completion: nil)
                })
            }
            
            alert.addAction(actionDestroy)
            alert.addAction(actionCancel)
            
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        }
    }

}

extension UpdateInfoViewController {
    
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
}
