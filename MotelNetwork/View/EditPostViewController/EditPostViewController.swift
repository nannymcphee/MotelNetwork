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


class EditPostViewController: UIViewController, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

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
    @IBOutlet weak var tfUsersAllowed: UITextField!

    var currentNews = News()
    var selectedAssets = [PHAsset]()
    var imageArray = [UIImage]()
    var currentDate: String = ""
    var dbReference: DatabaseReference!
    var currentNewsLatitude: String = ""
    var currentNewsLongitude: String = ""
    let uid = Auth.auth().currentUser?.uid
    let pvDistrict = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pvDistrict.delegate = self
        pvDistrict.dataSource = self
        
        self.tapToDismissKeyboard()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set up view
    func setUpView() {
        
        createDistrictListPicker()
        
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
        tfUsersAllowed.text = currentNews.usersAllowed
    }
    
    func convertAddressToCoordinate(address: String) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placemark, error) in
            if let placemark = placemark {
                if placemark.count != 0 {
                    let location = placemark.first?.location
                    let coordinate: CLLocationCoordinate2D = (location?.coordinate)!
                    let latStr = String(coordinate.latitude)
                    let longStr = String(coordinate.longitude)
                    let values = ["lat": latStr, "long": longStr]
                    let postID = self.currentNews.id
                    let reference = Database.database().reference().child("Posts").child(postID!)
                    
                    self.editData(reference: reference, newValues: values as [String : AnyObject])
                }
            }
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
    
    //Mark: Logic for BSImageViewPicker
    
    func showImageViewPicker() {
        
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 3
        vc.cancelButton.title = "Đóng"
        vc.doneButton.title = "Xong"
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
                
                let data = UIImageJPEGRepresentation(thumbnail, 1.0)
                let newImage = UIImage(data: data!)
                
                self.imageArray.append((newImage as UIImage?)!)
            }
            
            DispatchQueue.main.async {
                self.ivPostImage0.image = self.imageArray[0]
                self.ivPostImage1.image = self.imageArray[1]
                self.ivPostImage2.image = self.imageArray[2]
            }

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
    
    @IBAction func btnInfoPressed(_ sender: Any) {
        
        showAlert(alertMessage: "Việc nhập đúng định dạng địa chỉ sẽ giúp tin của bạn hiển thị chính xác trên bản đồ và những người dùng khác định vị chính xác hơn.")
    }
    
    @IBAction func btnAddImagePressed(_ sender: Any) {
        
        showImageViewPicker()
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }

    @IBAction func btnSavePressed(_ sender: Any) {

        
        if (self.tfArea.text?.isEmpty)! || (self.tfTitle.text?.isEmpty)! || (self.tfAddress.text?.isEmpty)! || (self.tvDescription.text?.isEmpty)! || (self.tfDistrict.text?.isEmpty)! || (self.tfRoomPrice.text?.isEmpty)! || (self.tfWaterPrice.text?.isEmpty)! || (self.tfElectricPrice.text?.isEmpty)! || (self.tfInternetPrice.text?.isEmpty)! || (self.tfPhoneNumber.text?.isEmpty)! || (self.tfUsersAllowed.text?.isEmpty)! {
            
            self.showAlert(alertMessage: messageNilTextFields)
        }
        else {
            
            let ownerID = Auth.auth().currentUser?.uid
            let title = self.tfTitle.text!
            let area = self.tfArea.text!
            let district = self.tfDistrict.text!
            var address: String = ""
            let waterPrice = self.tfWaterPrice.text!
            let phoneNumber = self.tfPhoneNumber.text!
            let electricPrice = self.tfElectricPrice.text!
            let price = self.tfRoomPrice.text!
            let description = self.tvDescription.text!
            let internetPrice = self.tfInternetPrice.text!
            let postID = currentNews.id
            let usersAllowed = self.tfUsersAllowed.text!
            let timestamp = Int(NSDate().timeIntervalSince1970)
            let ref = Database.database().reference().child("Posts").child(postID!)
            
            if (self.tfDistrict.text?.elementsEqual(currentNews.district!))! {
                address = self.tfAddress.text!
            }
            else {
                address = ("\(self.tfAddress.text!)" + ", \(district)")
            }

            let values = ["title": title, "description": description, "address": address, "district": district, "price": price, "electricPrice": electricPrice, "waterPrice": waterPrice, "internetPrice": internetPrice, "area": area, "phoneNumber": phoneNumber, "timestamp": timestamp, "ownerID": ownerID!, "usersAllowed": usersAllowed] as [String: AnyObject]
            
            // Create confirm alert
            let alert = UIAlertController(title: "Thông báo", message: messageConfirmEditData, preferredStyle: .alert)
            let actionDestroy = UIAlertAction(title: "Có", style: .destructive) { (action) in
                
               
                
                if self.ivPostImage0.image == nil || self.ivPostImage1.image == nil || self.ivPostImage2 == nil {
                    
                    self.convertAddressToCoordinate(address: address)
                    self.editData(reference: ref, newValues: values as [String: AnyObject])
                    self.showAlert(alertMessage: messageEditPostSuccess)
                }
                else {
                    
                    self.convertAddressToCoordinate(address: address)
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
                }
                self.showAlert(alertMessage: messageEditPostSuccess)
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
