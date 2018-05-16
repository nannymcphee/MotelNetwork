//
//  CreateNotificationViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/20/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateNotificationViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tvContent: UITextView!
    
    var currentRoom = Room()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }
    
    func setUpView() {
        
        tvContent.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSavePressed(_ sender: Any) {
        
        if (tfTitle.text?.isEmpty)! || (tvContent.text?.isEmpty)! {
            
            self.showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
        }
        else {
            
            let title = self.tfTitle.text!
            let content = self.tvContent.text!
            let renterID = currentRoom.renterID
            let ownerID = currentRoom.ownerID
            let roomID = currentRoom.id
            let timestamp = Int(NSDate().timeIntervalSince1970)
            let values = ["title": title, "content": content, "ownerID": ownerID ?? "", "renterID": renterID ?? "", "roomID": roomID ?? "", "timestamp": timestamp] as [String: AnyObject]
            let ref = Database.database().reference().child("Notifications").childByAutoId()
            
            self.storeInformationToDatabase(reference: ref, values: values)
        }
        self.showAlert(title: "Thông báo", alertMessage: messageCreateNotiSuccess)
    }
    
 

}
