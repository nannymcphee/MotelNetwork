//
//  EditPostViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/15/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Photos
import BSImagePicker

class EditPostViewController: UIViewController, UIImagePickerControllerDelegate {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var btnClearTextView: UIButton!
    @IBOutlet weak var ivPostImage0: UIImageView!
    @IBOutlet weak var ivPostImage1: UIImageView!
    @IBOutlet weak var ivPostImage2: UIImageView!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfDistrict: UITextField!
    @IBOutlet weak var tfRoomPrice: UITextField!
    @IBOutlet weak var tfElectricPrice: UITextField!
    @IBOutlet weak var tfWaterPrice: UITextField!
    @IBOutlet weak var tfInternetPrice: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var tfArea: UITextField!

    var currentNews = News()
    var selectedAssets = [PHAsset]()
    var imageArray = [UIImage]()
    var currentDate: String = ""
    var dbReference: DatabaseReference!
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tapToDismissKeyboard()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set up view
    func setUpView() {
        
        getCurrentDate()
        
        tfTitle.text = currentNews.title
        tvDescription.text = currentNews.description
        tfAddress.text = currentNews.address
        tfDistrict.text = currentNews.district
        tfRoomPrice.text = "\(currentNews.price ?? 0.0)"
        tfElectricPrice.text = "\(currentNews.electricPrice ?? 0.0)"
        tfWaterPrice.text = "\(currentNews.waterPrice ?? 0.0)"
        tfInternetPrice.text = "\(currentNews.internetPrice ?? 0.0)"
        tfPhoneNumber.text = currentNews.phoneNumber
        tfArea.text = currentNews.area
        
    }
    
    func getCurrentDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let str = formatter.string(from: Date())
        currentDate = str
    }
    
    //Mark: Logic for BSImageViewPicker
    
    func showImageViewPicker() {
        
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 3
        self.bs_presentImagePickerController(vc, animated: true, select: { (asset: PHAsset) in
        }, deselect: { (asset: PHAsset) in
            
        }, cancel: { (asset: [PHAsset]) in
            
        }, finish: { (asset: [PHAsset]) in
            
            if asset.count < 3 {
                self.showAlert(alertMessage: "Vui lòng chọn 3 hình.")
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
            
            self.ivPostImage0.image = imageArray[0]
            self.ivPostImage1.image = imageArray[1]
            self.ivPostImage2.image = imageArray[2]
        }
    }
    
    //MARK: Database interaction
    
    // Upload image from UIImageView to storage and return download url
    func uploadImageFromImageView(imageView : UIImageView, completion: @escaping ((String) -> (Void))) {
        
        var strURL = ""
        let uid = Auth.auth().currentUser?.uid
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("PostImages").child(uid!).child("\(imageName).jpg")
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
    @IBAction func btnClearTextViewPressed(_ sender: Any) {
        
        tvDescription.text = ""
    }
    
    @IBAction func btnAddImagePressed(_ sender: Any) {
        
        showImageViewPicker()
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }

    @IBAction func btnSavePressed(_ sender: Any) {

        
        if (self.tfArea.text?.isEmpty)! || (self.tfTitle.text?.isEmpty)! || (self.tfAddress.text?.isEmpty)! || (self.tvDescription.text?.isEmpty)! || (self.tfDistrict.text?.isEmpty)! || (self.tfRoomPrice.text?.isEmpty)! || (self.tfWaterPrice.text?.isEmpty)! || (self.tfElectricPrice.text?.isEmpty)! || (self.tfInternetPrice.text?.isEmpty)! || (self.tfPhoneNumber.text?.isEmpty)! {
            
            self.showAlert(alertMessage: messageNilTextFields)
        }
        else {
            
            let title = self.tfTitle.text!
            let area = self.tfArea.text!
            let district = self.tfDistrict.text!
            let address = self.tfAddress.text!
            let waterPrice = self.tfWaterPrice.text!
            let phoneNumber = self.tfPhoneNumber.text!
            let electricPrice = self.tfElectricPrice.text!
            let price = self.tfRoomPrice.text!
            let description = self.tvDescription.text!
            let internetPrice = self.tfInternetPrice.text!
            let postDate = currentDate
            let postID = currentNews.id
            let ref = Database.database().reference().child("Posts").child(self.uid!).child("MyPosts").child(postID!)
            let values = ["title": title, "description": description, "address": address, "district": district, "price": price, "electricPrice": electricPrice, "waterPrice": waterPrice, "internetPrice": internetPrice, "area": area, "phoneNumber": phoneNumber, "postDate": postDate]
            
            // Create confirm alert
            let alert = UIAlertController(title: "Thông báo", message: messageConfirmEditData, preferredStyle: .alert)
            let actionDestroy = UIAlertAction(title: "Có", style: .destructive) { (action) in
                
                
                if self.ivPostImage0.image == nil || self.ivPostImage1.image == nil || self.ivPostImage2 == nil {
                    
                    self.editData(reference: ref, newValues: values as [String: AnyObject])
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                        self.showAlert(alertMessage: messageEditPostSuccess)
                    })
                }
                else {
                    
                    self.editData(reference: ref, newValues: values as [String: AnyObject])
                    
                    // Upload image to Firebase storage and update download urls into database
                    
                    _ = self.uploadImageFromImageView(imageView: self.ivPostImage0) { (url) in
                        self.editData(reference: ref, newValues: ["postImageUrl0": url as AnyObject])
                    }
                    
                    _ = self.uploadImageFromImageView(imageView: self.ivPostImage1) { (url) in
                        self.editData(reference: ref, newValues: ["postImageUrl1": url as AnyObject])
                    }
                    
                    _ = self.uploadImageFromImageView(imageView: self.ivPostImage2) { (url) in
                        self.editData(reference: ref, newValues: ["postImageUrl2": url as AnyObject])
                    }
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                        self.showAlert(alertMessage: messageEditPostSuccess)
                    })
                }
                
                return
            }
            
            let actionCancel = UIAlertAction(title: "Không", style: .cancel) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(actionDestroy)
            alert.addAction(actionCancel)
            
            self.present(alert, animated: true, completion: nil)
        }
    }

}
