//
//  BillManagementViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/19/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class BillManagementViewController: UIViewController {
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    
    var userList = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        fetchUser()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: Database interaction
    
    // Fetch user from database and add to user list
    func fetchUser() {
        
//        let ref = Database.database().reference()
//        let query = ref.child("Users").queryEqual(toValue: "241447624")
//
//        query.observe(.childAdded, with: { (snapshot) in
//
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                let user = User(dictionary: dictionary)
//                user.id = snapshot.key
//                self.userList.append(user)
//
//                DispatchQueue.main.async(execute: {
//                    self.reloadInputViews()
//                })
//            }
//
//        }, withCancel: nil)
        
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
    
    
    

}
