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
    
    
    var userList = [User]()
    let pvUser = UIPickerView()
    var selectedAssets = [PHAsset]()
    var imageArray = [UIImage]()
    let roomID = UUID().uuidString
    
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
        
        makeButtonRounded(button: btnSave)
        checkAuthStatus()
        fetchUser()
        createUsersListPicker()
    }
    
    //MARK: Database interaction
    
    // Fetch user from database
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
    
    // Store room's info to database
    private func storeRoomInformationToDatabase(_ uid: String, values: [String: AnyObject]) {
        
        // Create database references
        let dbRef = Database.database().reference()
        let roomRef = dbRef.child("Rooms").child(uid).child("MyRooms").child("\(roomID)")
        
        roomRef.updateChildValues(values) { (error, ref) in
            
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
        let storageRef = Storage.storage().reference().child("RoomImages").child(uid!).child("\(imageName).jpg")
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
    
    
    //MARK: Logic for tfUser
    
    func createUsersListPicker() {
        
        // Add toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Add "Done" button
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(btnDonePressed))
        toolbar.setItems([btnDone], animated: false)
        
        self.tfUser.inputView = self.pvUser
        self.tfUser.inputAccessoryView = toolbar
    }
    
    @objc func btnDonePressed() {
        self.view.endEditing(false)
    }
    
    //MARK: Logic for UITableView
    
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
        //        let selectedUserType = pvUser.selectedRow(inComponent: 0)
        //        let userType2 = userType[selectedUserType].userType
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
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
        
        // Check if user has entered all informations
        if tfUser.text == nil || tfArea.text == nil || tfPrice.text == nil || tfRoomName.text == nil {
            
            // Create UIAlertController
            let alert = UIAlertController(title: "Thông báo", message: "Vui lòng nhập đầy đủ thông tin!", preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            })
            alert.addAction(actionOK)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            
            // Store room's info to database
            let roomName = self.tfRoomName.text!
            let area = self.tfArea.text!
            let price = self.tfPrice.text!
            let user = self.tfUser.text!
            let values = ["RoomName": roomName, "Area": area, "Price": price, "User": user, "roomImageUrl0": "", "roomImageUrl1": "", "roomImageUrl2": ""]
            
            self.storeRoomInformationToDatabase(uid, values: values as [String: AnyObject])
            
            // Upload image to Firebase storage and update download urls into database
            
            _ = uploadImageFromImageView(imageView: ivRoomImage0) { (url) in
                self.storeRoomInformationToDatabase(uid, values: ["roomImageUrl0": url as AnyObject])
            }
            
            _ = uploadImageFromImageView(imageView: ivRoomImage1) { (url) in
                self.storeRoomInformationToDatabase(uid, values: ["roomImageUrl1": url as AnyObject])
            }
            
            _ = uploadImageFromImageView(imageView: ivRoomImage2) { (url) in
                self.storeRoomInformationToDatabase(uid, values: ["roomImageUrl2": url as AnyObject])
            }
        }
        
        showAlert(alertMessage: "Tạo phòng thành công!")
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
            
            self.ivRoomImage0.image = imageArray[0]
            self.ivRoomImage1.image = imageArray[1]
            self.ivRoomImage2.image = imageArray[2]
        }
    }
    
    //MARK: Check auth status and handle log out
    
    func checkAuthStatus() {
        
        if Auth.auth().currentUser?.uid == nil {
            
            performSelector(onMainThread: #selector(handleLogout), with: nil, waitUntilDone: true)
        }
        else {
            
//            let uid = Auth.auth().currentUser?.uid
//            Database.database().reference().child("Users").child(uid!).child("FullName").observeSingleEvent(of: .value, with: { (snapshot) in
//
//                print(snapshot)
//            }, withCancel: nil)
        }
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
