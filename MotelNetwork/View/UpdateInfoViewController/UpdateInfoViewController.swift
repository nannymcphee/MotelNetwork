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

class UpdateInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var ivProfileImage: UIImageView!
    
    let uid = Auth.auth().currentUser?.uid
    var profileImageUrl: String?
    var imageArray = [UIImage]()
    var selectedAssets = [PHAsset]()
    
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
                let userName = dictionary["FullName"] as? String
                self.profileImageUrl = dictionary["ProfileImageUrl"] as? String
                self.tfUserName.text = userName
            }
        }, withCancel: nil)
        
        self.tapToDismissKeyboard()
        makeImageViewRounded(imageView: ivProfileImage)
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
                self.imageArray.append(newImage as! UIImage)
            }
            
            self.ivProfileImage.image = imageArray[0]
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
        vc.doneButton.title = "Xong"
        self.bs_presentImagePickerController(vc, animated: true, select: { (asset: PHAsset) in
            
        }, deselect: { (asset: PHAsset) in
            
        }, cancel: { (asset: [PHAsset]) in
            
        }, finish: { (asset: [PHAsset]) in
            
            if asset.count < 1 {
                self.showAlert(alertMessage: "Vui lòng chọn 1 hình.")
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
        
        if (tfUserName.text?.isEmpty)! {
            
            self.showAlert(alertMessage: messageNilTextFields)
        }
        else {
            
            let userName = self.tfUserName.text!
            let values = ["FullName": userName, "ProfileImageUrl": self.profileImageUrl]
            let ref = Database.database().reference().child("Users").child(uid!)

            // Create confirm alert
            let alert = UIAlertController(title: "Thông báo", message: messageConfirmEditData, preferredStyle: .alert)
            let actionDestroy = UIAlertAction(title: "Có", style: .destructive) { (action) in
                
                if (self.tfUserName.text?.isEmpty)! {
                    
                    self.showAlert(alertMessage: messageNilTextFields)
                }
                else if self.ivProfileImage.image == nil {
                    
                    self.editData(reference: ref, newValues: values as [String: AnyObject])
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                        self.showAlert(alertMessage: messageEditRoomSuccess)
                    })
                }
                else {
                    
                    self.editData(reference: ref, newValues: values as [String: AnyObject])
                    
                    // Upload image to Firebase storage and update download urls into database
                    
                    _ = self.uploadImageFromImageView(imageView: self.ivProfileImage) { (url) in
                        self.editData(reference: ref, newValues: ["ProfileImageUrl": url as AnyObject])
                    }
                }
                
                self.showAlert(alertMessage: messageEditInfoSuccess)
                
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
