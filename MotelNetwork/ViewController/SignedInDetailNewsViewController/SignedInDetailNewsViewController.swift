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
        
        self.ivAvatar.layer.cornerRadius = self.ivAvatar.frame.size.width / 2
        ivAvatar.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnBack2Pressed(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
