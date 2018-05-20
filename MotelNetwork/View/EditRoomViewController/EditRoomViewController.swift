//
//  EditRoomViewController.swift
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

class EditRoomViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate {

    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfUsersAllowed: UITextField!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var ivRoomImage0: UIImageView!
    @IBOutlet weak var ivRoomImage1: UIImageView!
    @IBOutlet weak var ivRoomImage2: UIImageView!
    @IBOutlet weak var tfRoomName: UITextField!
    @IBOutlet weak var tfArea: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfUser: UITextField!
    
    let pvUser = UIPickerView()
    var currentRoom = Room()
    var userList = [User]()
    var urlArray = [String]()
    var imageArray = [UIImage]()
    var selectedAssets = [PHAsset]()
 
    let uid = Auth.auth().currentUser?.uid
    
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
    
    func setUpView() {
        
        checkAuthStatus()
        fetchUser()
        createUsersListPicker()
        tfArea.text = currentRoom.area
        tfPrice.text = "\(currentRoom.price ?? 0.0)"
        tfRoomName.text = currentRoom.name
        tfUsersAllowed.text = currentRoom.usersAllowed
        tfAddress.text = currentRoom.address
        
        if let renterID = currentRoom.renterID {
            if renterID.isEmpty {
                
                self.tfUser.text = ""
            }
            else {
                
                let ref = Database.database().reference().child("Users").child(renterID)
                
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        self.tfUser.text = dictionary["FullName"] as? String
                    }
                }, withCancel: nil)
            }
        }
        
        self.tapToDismissKeyboard()
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
                
                let data = UIImageJPEGRepresentation(thumbnail, 0.75)
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
    
    //MARK: Database interaction
    
    // Fetch user from database and add to user list
    func fetchUser() {
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key
                
                
                DispatchQueue.main.async(execute: {
                    self.reloadInputViews()
                })
                
                // Fetch user's full name
                user.name = dictionary["FullName"] as? String
                self.userList.append(user)
            }
        }, withCancel: nil)
    }
    
    // Remove old image from storage (in case user change room's image)
    func removeOldImageFromStorage() {
        let roomImageUrl0 = currentRoom.roomImageUrl0!
        let roomImageUrl1 = currentRoom.roomImageUrl1!
        let roomImageUrl2 = currentRoom.roomImageUrl2!
        let storageRef0 = Storage.storage().reference(forURL: roomImageUrl0)
        let storageRef1 = Storage.storage().reference(forURL: roomImageUrl1)
        let storageRef2 = Storage.storage().reference(forURL: roomImageUrl2)
        
        deleteFromStorage(storageRef: storageRef0)
        deleteFromStorage(storageRef: storageRef1)
        deleteFromStorage(storageRef: storageRef2)
    }
    
    // Upload image from UIImageView to storage and return download url
    func uploadImageFromImageView(imageView : UIImageView, completion: @escaping ((String) -> (Void))) {
        
        var strURL = ""
        let uid = Auth.auth().currentUser?.uid
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("RoomImages").child(uid!).child("\(imageName).jpg")
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
        
        let roomName = self.tfRoomName.text!
        let area = self.tfArea.text!
        let price = self.tfPrice.text!
        let renterName = self.tfUser.text!
        let usersAllowed = self.tfUsersAllowed.text!
        let address = self.tfAddress.text!
        let roomID = currentRoom.id
        let ownerID = Auth.auth().currentUser?.uid
        let renterID = currentRoom.renterID
        let roomImageUrl0 = currentRoom.roomImageUrl0!
        let roomImageUrl1 = currentRoom.roomImageUrl1!
        let roomImageUrl2 = currentRoom.roomImageUrl2!
        
        if area.isEmpty || address.isEmpty || price.isEmpty || roomName.isEmpty || usersAllowed.isEmpty {
            
            self.showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
        }
        else if address.count > 50 {
            
            self.showAlert(title: "Thông báo", alertMessage: messageLimitCharacters)
        }
        else {
        
            let ref = Database.database().reference().child("Rooms").child(roomID!)
            let values = ["roomName": roomName, "area": area, "price": price, "ownerID": ownerID, "renterID": renterID, "roomImageUrl0": roomImageUrl0, "roomImageUrl1": roomImageUrl1, "roomImageUrl2": roomImageUrl2, "usersAllowed": usersAllowed, "address": address, "renterName": renterName]
    
            // Create confirm alert
            let alert = UIAlertController(title: "Thông báo", message: messageConfirmEditData, preferredStyle: .alert)
            let actionDestroy = UIAlertAction(title: "Có", style: .destructive) { (action) in

                 if self.ivRoomImage0.image == nil || self.ivRoomImage1.image == nil || self.ivRoomImage2 == nil {
                    
                    self.editData(reference: ref, newValues: values as [String: AnyObject])
                    
                    if renterName.isEmpty {
                        
                        let values = ["renterName": "", "renterID": ""] as [String: AnyObject]
                        self.editData(reference: ref, newValues: values)
                    }
                    else {
                        
                        // Get renter's id by renter's name and save to room in database
                        let renterRef = Database.database().reference().child("Users")
                        let query = renterRef.queryOrdered(byChild: "FullName").queryEqual(toValue: renterName)
                        query.observeSingleEvent(of: .value) { (snapshot) in
                            
                            let renterID = snapshot.key
                            
                            self.editData(reference: ref, newValues: ["renterID": renterID as AnyObject])
                        }
                    }
                    
                    NativePopup.show(image: Preset.Feedback.done, title: messageEditInfoSuccess, message: nil, duration: 1.5, initialEffectType: .fadeIn)
                }
                else {
                    
                    self.removeOldImageFromStorage()
                    
                    if renterName.isEmpty {
                        
                        for image in self.imageArray {
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
                        
                        // Get renter's id by renter's name and save to room in database
                        let renterRef = Database.database().reference().child("Users")
                        let query = renterRef.queryOrdered(byChild: "FullName").queryEqual(toValue: renterName)
                        query.observeSingleEvent(of: .childAdded) { (snapshot) in
                            
                            let renterID = snapshot.key
                            
                            self.storeInformationToDatabase(reference: ref, values: ["renterID": renterID as AnyObject])
                        }
                        
                        for image in self.imageArray {
                            self.uploadImage(image: image) { (url) -> (Void) in
                                
                                self.urlArray.append(url)
                                
                                for url in self.urlArray {
                                    let values = ["roomName": roomName, "area": area, "price": price, "ownerID": ownerID, "roomImageUrl\(self.urlArray.index(of: url) ?? 0)": url, "usersAllowed": usersAllowed, "address": address, "renterName": renterName] as [String: AnyObject]
                                    self.storeInformationToDatabase(reference: ref, values: values)
                                }
                            }
                        }
                    }
                    
                    NativePopup.show(image: Preset.Feedback.done, title: messageEditInfoSuccess, message: nil, duration: 1.5, initialEffectType: .fadeIn)
                }
                
                // Get renter's id by renter's name and save to room in database
                let renterRef = Database.database().reference().child("Users")
                let query = renterRef.queryOrdered(byChild: "FullName").queryEqual(toValue: renterName)
                query.observeSingleEvent(of: .childAdded) { (snapshot) in
                    
                    let renterID = snapshot.key
                    
                    self.storeInformationToDatabase(reference: ref, values: ["renterID": renterID as AnyObject])
                }
                
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

