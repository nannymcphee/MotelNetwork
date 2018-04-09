//
//  SignedInDetailNewsViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/4/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class SignedInDetailNewsViewController: UIViewController {
    
    
    @IBOutlet weak var btnBack2: UIButton!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    
    var dbReference: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
        // Do any additional setup after loading the view.
    }
    
    func setUpView() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            return
        }
        
        dbReference = Database.database().reference()
        dbReference.child("Users").child(uid).observe(.value) { (snapshot) in
            
            // Get user value
            let value = snapshot.value as! NSDictionary
            let userName = value["FullName"] as? String ?? ""
            let profileImageUrl = value["ProfileImageUrl"] as? String ?? ""
            
            self.lblUserName.text = userName
            self.ivAvatar.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        makeImageViewRounded(imageView: ivAvatar)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnBack2Pressed(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    
    
    
}
