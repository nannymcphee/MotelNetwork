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
import Alamofire
import SwiftyJSON
import Kingfisher

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
    var urlArray = [String]()
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
        tfRoomPrice.text = "\(currentNews.price ?? "")"
        tfElectricPrice.text = "\(currentNews.electricPrice ?? "")"
        tfWaterPrice.text = "\(currentNews.waterPrice ?? "")"
        tfInternetPrice.text = "\(currentNews.internetPrice ?? "")"
        tfPhoneNumber.text = currentNews.phoneNumber
        tfArea.text = currentNews.area
        tfUsersAllowed.text = currentNews.usersAllowed
        ivPostImage0.layer.cornerRadius = 10
        ivPostImage1.layer.cornerRadius = 10
        ivPostImage2.layer.cornerRadius = 10
        
        if currentNews.postImageUrl0 != nil || currentNews.postImageUrl1 != nil || currentNews.postImageUrl2 != nil {
            let resource0 = ImageResource(downloadURL: URL(string: currentNews.postImageUrl0!)!)
            let resource1 = ImageResource(downloadURL: URL(string: currentNews.postImageUrl1!)!)
            let resource2 = ImageResource(downloadURL: URL(string: currentNews.postImageUrl2!)!)
            
            ivPostImage0.kf.setImage(with: resource0, placeholder: #imageLiteral(resourceName: "defaultImage"), options: nil, progressBlock: nil, completionHandler: nil)
            ivPostImage1.kf.setImage(with: resource1, placeholder: #imageLiteral(resourceName: "defaultImage"), options: nil, progressBlock: nil, completionHandler: nil)
            ivPostImage2.kf.setImage(with: resource2, placeholder: #imageLiteral(resourceName: "defaultImage"), options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            ivPostImage0.image = #imageLiteral(resourceName: "defaultImage")
            ivPostImage1.image = #imageLiteral(resourceName: "defaultImage")
            ivPostImage2.image = #imageLiteral(resourceName: "defaultImage")
        }
    }
    
    //MARK: Geocode address using Google Geocoding API
    
    func geocodeAddress(address: String, dbRef: DatabaseReference) {
        
        let postParameters:[String: Any] = [ "address": address,"key":API_KEY]
        let url : String = "https://maps.googleapis.com/maps/api/geocode/json"

        Alamofire.request(url, method: .get, parameters: postParameters, encoding: URLEncoding.default, headers: nil).responseJSON {  response in

            if let receivedResults = response.result.value
            {
                let resultParams = JSON(receivedResults)
                let lat = resultParams["results"][0]["geometry"]["location"]["lat"].stringValue
                let long = resultParams["results"][0]["geometry"]["location"]["lng"].stringValue
                let values = ["lat": lat, "long": long]
                
                self.editData(reference: dbRef, newValues: values as [String : AnyObject])
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
        
        if let uploadImageData = UIImageJPEGRepresentation(imageView.image!, 1.0) {
            
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
        
        if let uploadImageData = UIImageJPEGRepresentation(image, 0.8) {
            
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
    
    // Remove old image from storage (in case user change room's image)
    func removeOldImageFromStorage() {
        let postImageUrl0 = currentNews.postImageUrl0!
        let postImageUrl1 = currentNews.postImageUrl1!
        let postImageUrl2 = currentNews.postImageUrl2!
        let storageRef0 = Storage.storage().reference(forURL: postImageUrl0)
        let storageRef1 = Storage.storage().reference(forURL: postImageUrl1)
        let storageRef2 = Storage.storage().reference(forURL: postImageUrl2)
        
        deleteFromStorage(storageRef: storageRef0)
        deleteFromStorage(storageRef: storageRef1)
        deleteFromStorage(storageRef: storageRef2)
    }
    
    //MARK: Handle button pressed
    @IBAction func btnClearTextViewPressed(_ sender: Any) {
        
        tvDescription.text = ""
    }
    
    @IBAction func btnInfoPressed(_ sender: Any) {
        
        showAlert(title: "Lưu ý", alertMessage: "Việc nhập đúng định dạng địa chỉ sẽ giúp tin của bạn hiển thị chính xác trên bản đồ và những người dùng khác định vị chính xác hơn.")
    }
    
    @IBAction func btnAddImagePressed(_ sender: Any) {
        
        showImageViewPicker()
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }

    @IBAction func btnSavePressed(_ sender: Any) {

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
        let timestampEdit = Int(NSDate().timeIntervalSince1970)
        var addressTemp = self.tfAddress.text!
        
        if area.isEmpty || title.isEmpty || addressTemp.isEmpty || description.isEmpty || district.isEmpty || price.isEmpty || waterPrice.isEmpty || electricPrice.isEmpty || internetPrice.isEmpty || phoneNumber.isEmpty || usersAllowed.isEmpty {
            
            self.showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
        }
        else {
            
            let ref = Database.database().reference().child("Posts").child(postID!)
            
            if (district.elementsEqual(currentNews.district!)) {
                address = addressTemp
            }
            else {
                if let range = addressTemp.range(of: ",") {
                    addressTemp.removeSubrange(range.lowerBound..<addressTemp.endIndex)
                    address = ("\(addressTemp)" + ", \(district)")
                }
            }
            
            if (addressTemp.elementsEqual(currentNews.address!)) {
                address = addressTemp
            }
            else {
                address = ("\(addressTemp)" + ", \(district)")
            }

            // Removed value "timestamp": timestamp
            let values = ["title": title, "description": description, "address": address, "district": district, "price": price, "electricPrice": electricPrice, "waterPrice": waterPrice, "internetPrice": internetPrice, "area": area, "phoneNumber": phoneNumber, "ownerID": ownerID!, "usersAllowed": usersAllowed, "timestampEdit": timestampEdit, "id": postID ?? ""] as [String: AnyObject]
            
            // Create confirm alert
            let alert = UIAlertController(title: "Thông báo", message: messageConfirmEditData, preferredStyle: .alert)
            let actionDestroy = UIAlertAction(title: "Có", style: .destructive) { (action) in
                
                if self.ivPostImage0.image == nil || self.ivPostImage1.image == nil || self.ivPostImage2 == nil {
                    
                    self.geocodeAddress(address: address, dbRef: ref)
                    self.editData(reference: ref, newValues: values as [String: AnyObject])
                    NativePopup.show(image: Preset.Feedback.done, title: messageEditPostSuccess, message: nil, duration: 1.5, initialEffectType: .fadeIn)
                }
                else {
                    
                    self.geocodeAddress(address: address, dbRef: ref)
                    self.removeOldImageFromStorage()
                    self.editData(reference: ref, newValues: values as [String: AnyObject])
                    
                    for image in self.imageArray {
                        self.uploadImage(image: image) { (url) -> (Void) in
                            
                            self.urlArray.append(url)
                            
                            for url in self.urlArray {
                                let values = ["postImageUrl\(self.urlArray.index(of: url) ?? 0)": url] as [String : AnyObject]
                                self.editData(reference: ref, newValues: values)
                            }
                        }
                    }
                }
                
                NativePopup.show(image: Preset.Feedback.done, title: messageEditPostSuccess, message: nil, duration: 1.5, initialEffectType: .fadeIn)
   
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
