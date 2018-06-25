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
import GoogleMaps
import Alamofire
import SwiftyJSON

class NewPostViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var sclContent: UIScrollView!
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
    @IBOutlet weak var tfUsersAllowed: UITextField!
    
    let pvDistrict = UIPickerView()
    var selectedAssets = [PHAsset]()
    var imageArray = [UIImage]()
    var urlArray = [String]()
    var currentDate: String = ""
    var dbReference: DatabaseReference!
    var currentNewsLatitude: String = ""
    var currentNewsLongitude: String = ""
    var postImageUrl0: String = ""
    var postImageUrl1: String = ""
    var postImageUrl2: String = ""
	
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
    
    //MARK: Geocode address using Google Geocoding API
    
    func geocodeAddress(address: String) {
        
        let postParameters:[String: Any] = [ "address": address,"key":API_KEY]
        let url : String = "https://maps.googleapis.com/maps/api/geocode/json"
        
        Alamofire.request(url, method: .get, parameters: postParameters, encoding: URLEncoding.default, headers: nil).responseJSON {  response in
            
            if let receivedResults = response.result.value
            {
                let resultParams = JSON(receivedResults)
                let lat = resultParams["results"][0]["geometry"]["location"]["lat"].stringValue
                let long = resultParams["results"][0]["geometry"]["location"]["lng"].stringValue
                
                self.currentNewsLatitude = lat
                self.currentNewsLongitude = long
            }
        }
    }
    
    //MARK: Set up view
    
    func setUpView() {
        
        fetchUser()
        createDistrictListPicker()
        self.tapToDismissKeyboard()
        makeButtonRounded(button: btnClearTextView)
        ivPostImage0.layer.cornerRadius = 10
        ivPostImage1.layer.cornerRadius = 10
        ivPostImage2.layer.cornerRadius = 10
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
        self.tfUsersAllowed.text = ""
    }
    
    //Mark: Convert selected assets to image
    
    func convertAssetToImages() -> Void {
        
        if selectedAssets.count != 0 {
            
            for i in 0..<selectedAssets.count {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: selectedAssets[i], targetSize: CGSize(width: 375, height: 360), contentMode: .aspectFill, options: option) { (result, info) in
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
        
        if let uploadImageData = UIImageJPEGRepresentation(imageView.image!, 0.8) {
            
            storeImage.putData(uploadImageData, metadata: nil, completion: { (metaData, error) in
                storeImage.downloadURL(completion: { (url, error) in
                    if let urlText = url?.absoluteString {
                        
                        strURL = urlText
                        
                        completion(strURL)
                    }
                })
            })
        }
    }
    
    func uploadImage(image: UIImage, completion: @escaping ((String) -> (Void))) {
        
        var strURL = ""
        let uid = Auth.auth().currentUser?.uid
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("RoomImages").child(uid!).child("\(imageName).jpg")
        
        if let uploadImageData = UIImageJPEGRepresentation(image, 1.0) {
            
            storageRef.putData(uploadImageData, metadata: nil, completion: { (metaData, error) in
                storageRef.downloadURL(completion: { (url, error) in
                    if let urlText = url?.absoluteString {
                        
                        strURL = urlText
                        
                        completion(strURL)
                    }
                })
            })
        }
    }
    
    // Fetch user's phone number to tfPhoneNumber
    
    func fetchUser() {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("Users").child(uid!)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.tfPhoneNumber.text = dictionary["PhoneNumber"] as? String
            }
        }, withCancel: nil)
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
        
        imageArray.removeAll()
        selectedAssets.removeAll()
        
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 3
        self.bs_presentImagePickerController(vc, animated: true, select: { (asset: PHAsset) in
            
        }, deselect: { (asset: PHAsset) in
            
        }, cancel: { (asset: [PHAsset]) in
            
        }, finish: { (asset: [PHAsset]) in
            
            if asset.count < 3 {
                self.showAlert(title: "Thông báo", alertMessage: "Vui lòng chọn 3 hình.")
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
   
    @IBAction func btnInfoPressed(_ sender: Any) {
        
        showAlert(title: "Lưu ý", alertMessage: "Việc nhập đúng định dạng địa chỉ sẽ giúp tin của bạn hiển thị chính xác trên bản đồ và những người dùng khác định vị chính xác hơn.")
    }
    
    @IBAction func btnSavePressed(_ sender: Any) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let title = self.tfTitle.text!
        let area = self.tfArea.text!
        let district = self.tfDistrict.text!
        let address = ("\(self.tfAddress.text!)" + ", \(district)")
        let waterPrice = self.tfWaterPrice.text!
        let phoneNumber = self.tfPhoneNumber.text!
        let electricPrice = self.tfElectricPrice.text!
        let price = self.tfPrice.text!
        let description = self.tvDescription.text!
        let internetPrice = self.tfInternetPrice.text!
        let usersAllowed = self.tfUsersAllowed.text!
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let timestampEdit = 0
        
        if district.isEmpty || title.isEmpty || area.isEmpty || price.isEmpty || address.isEmpty || waterPrice.isEmpty || phoneNumber.isEmpty || electricPrice.isEmpty || internetPrice.isEmpty || description.isEmpty || usersAllowed.isEmpty {
            
            showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
        }
        else if ivPostImage0.image == nil || ivPostImage1.image == nil || ivPostImage2.image == nil {
            
            self.showAlert(title: "Thông báo", alertMessage: messageNilImages)
        }
        else if title.count > 50 || address.count > 50 {
            
            self.showAlert(title: "Thông báo", alertMessage: messageLimitCharacters)
        }
        else if !(price.isNumber) || !(internetPrice.isNumber) || !(waterPrice.isNumber) || !(electricPrice.isNumber) {
            
            self.showAlert(title: "Thông báo", alertMessage: "Vui lòng nhập đúng định dạng giá (Số).")
        }
        else {
            
            let ref = Database.database().reference().child("Posts").childByAutoId()
            let id = ref.key
            
            self.geocodeAddress(address: address)
            
            for image in self.imageArray {
                
                self.uploadImage(image: image) { (url) -> (Void) in
                    
                    self.urlArray.append(url)
                    
                    for url in self.urlArray {
                        
                        let values = ["postImageUrl\(self.urlArray.index(of: url) ?? 0)": url, "title": title, "description": description, "address": address, "district": district, "price": price, "electricPrice": electricPrice, "waterPrice": waterPrice, "internetPrice": internetPrice, "area": area, "phoneNumber": phoneNumber, "timestamp": timestamp, "ownerID": uid, "views": 0, "usersAllowed": usersAllowed, "timestampEdit": timestampEdit, "lat": self.currentNewsLatitude, "long": self.currentNewsLongitude, "id": id] as [String : AnyObject]
                        
                        self.storeInformationToDatabase(reference: ref, values: values)
                    }
                }
            }
            
            self.showLoading()
            self.resetView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.stopLoading()
                self.selectedAssets.removeAll()
                self.imageArray.removeAll()
                self.urlArray.removeAll()
                NativePopup.show(image: Preset.Feedback.done, title: messageNewPostSuccess, message: nil, duration: 1.5, initialEffectType: .fadeIn)
            }
        }
        
        return
    }
    
}
