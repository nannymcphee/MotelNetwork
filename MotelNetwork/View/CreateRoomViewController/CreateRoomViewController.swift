//
//  CreateRoomViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/5/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Photos
import BSImagePicker

class CreateRoomViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfUsersAllowed: UITextField!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var tfRoomName: UITextField!
    @IBOutlet weak var tfArea: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var ivRoomImage0: UIImageView!
    @IBOutlet weak var ivRoomImage1: UIImageView!
    @IBOutlet weak var ivRoomImage2: UIImageView!
    @IBOutlet weak var tfUser: UITextField!
    @IBOutlet weak var btnAddImage: UIButton!
    
    let pvUser = UIPickerView()
    var userList = [User]()
    var selectedAssets = [PHAsset]()
    var imageArray = [UIImage]()
    var urlArray = [String]()
    var renterID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pvUser.delegate = self
        pvUser.dataSource = self
        
        setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set up view
    
    func setUpView() {
        
        checkAuthStatus()
        fetchUser()
        createUsersListPicker()
        self.tapToDismissKeyboard()
    }
    
    //MARK: Reset view
    
    func resetView() {
        
        self.ivRoomImage0.image = nil
        self.ivRoomImage1.image = nil
        self.ivRoomImage2.image = nil
        self.tfArea.text = ""
        self.tfUser.text = ""
        self.tfPrice.text = ""
        self.tfRoomName.text = ""
        self.tfUsersAllowed.text = ""
        self.tfAddress.text = ""
    }
    
    //MARK: Database interaction
    
    // Fetch user from database and add to user list
    func fetchUser() {

        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key
                self.userList.append(user)
                
                DispatchQueue.main.async(execute: {
                    self.reloadInputViews()
                })
                
                // Fetch user's full name
                user.name = dictionary["FullName"] as? String
            }
        }, withCancel: nil)
    }
    
    // Get renterID by renterName
    
    func getRenterID(renterName: String) {
        
        let renterRef = Database.database().reference().child("Users")
        let query = renterRef.queryOrdered(byChild: "FullName").queryEqual(toValue: renterName)
        query.observeSingleEvent(of: .childAdded) { (snapshot) in
            
            let id = snapshot.key
            
            self.renterID = id
        }
    }
    
    // Upload image from UIImageView to storage and return download url
    func uploadImageFromImageView(imageView : UIImageView, completion: @escaping ((String) -> (Void))) {
        
        var strURL = ""
        let uid = Auth.auth().currentUser?.uid
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("RoomImages").child(uid!).child("\(imageName).jpg")
        
        if let uploadImageData = UIImageJPEGRepresentation(imageView.image!, 1.0) {
            
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
    
    //MARK: Logic for tfUser as UIPickerView
    
    func createUsersListPicker() {
        
        // Add toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Add "Done" button
        let btnDone = UIBarButtonItem(title: "Xong", style: .done, target: nil, action: #selector(btnDonePressed))
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btnDelete = UIBarButtonItem(title: "Xóa", style: .done, target: nil, action: #selector(btnDeletePressed))
        toolbar.setItems([btnDone, btnSpace, btnDelete], animated: false)
        
        self.tfUser.inputView = self.pvUser
        self.tfUser.inputAccessoryView = toolbar
    }
    
    @objc func btnDonePressed() {
        self.view.endEditing(false)
    }
    
    @objc func btnDeletePressed() {
        self.tfUser.text = ""
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return userList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return userList[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        pickerView.reloadComponent(0)
        tfUser.text = userList[row].name
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
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
    
    @IBAction func btnSavePressed(_ sender: Any) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let roomName = self.tfRoomName.text!
        let area = self.tfArea.text!
        let price = self.tfPrice.text!
        let renterName = self.tfUser.text!
        let usersAllowed = self.tfUsersAllowed.text!
        let address = self.tfAddress.text!
        
        // Check if user has entered all informations
        if  area.isEmpty || address.isEmpty || usersAllowed.isEmpty || price.isEmpty || roomName.isEmpty {
            
            self.showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
        }
        else if !(price.isNumber) {
            
            self.showAlert(title: "Thông báo", alertMessage: "Vui lòng nhập đúng định dạng giá phòng (Số).")
        }
        else if ivRoomImage0.image == nil || ivRoomImage1.image == nil || ivRoomImage2.image == nil {
            
            self.showAlert(title: "Thông báo", alertMessage: messageNilImages)
        }
        else {
        
            // Store room's info to database
            let ownerID = uid
            let ref = Database.database().reference().child("Rooms").childByAutoId()

            if renterName.isEmpty {
                
                for image in imageArray {
                    self.uploadImage(image: image) { (url) -> (Void) in
                        
                        self.urlArray.append(url)
                        
                        for url in self.urlArray {
                            let values = ["roomName": roomName, "area": area, "price": price, "ownerID": ownerID, "roomImageUrl\(self.urlArray.index(of: url) ?? 0)": url, "usersAllowed": usersAllowed, "address": address, "renterName": "", "renterID": ""] as [String: AnyObject]
                            
                            self.storeInformationToDatabase(reference: ref, values: values)
                        }
                    }
                }
            }
            else {
                
                self.getRenterID(renterName: renterName)

                for image in self.imageArray {
                    self.uploadImage(image: image) { (url) -> (Void) in
                        
                        self.urlArray.append(url)
                        
                        for url in self.urlArray {
                            let values = ["roomImageUrl\(self.urlArray.index(of: url) ?? 0)": url, "roomName": roomName, "area": area, "price": price, "ownerID": ownerID, "usersAllowed": usersAllowed, "address": address, "renterName": renterName, "renterID": self.renterID] as [String: AnyObject]
                            
                            self.storeInformationToDatabase(reference: ref, values: values)
                        }
                    }
                }
            }

            self.showLoading()
            self.selectedAssets.removeAll()
            self.imageArray.removeAll()
            self.resetView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.stopLoading()
                NativePopup.show(image: Preset.Feedback.done, title: messageCreateRoomSuccess, message: nil, duration: 1.5, initialEffectType: .fadeIn)

            }
        }

        return
    }
    
    //Mark: Convert selected assets to image    
    
    func convertAssetToImages() -> Void {
        
        if selectedAssets.count != 0 {
            
            for i in 0..<selectedAssets.count {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: selectedAssets[i], targetSize: CGSize(width: 375, height: 360), contentMode: .aspectFit, options: option) { (result, info) in
                    thumbnail = result!
                }
                
                let data = UIImageJPEGRepresentation(thumbnail, 1.0)
                let newImage = UIImage(data: data!)
                self.imageArray.append((newImage as UIImage?)!)
            }
            
            DispatchQueue.main.async {
                self.ivRoomImage0.image = self.imageArray[0]
                self.ivRoomImage1.image = self.imageArray[1]
                self.ivRoomImage2.image = self.imageArray[2]
            }
        }
    }
    

}
