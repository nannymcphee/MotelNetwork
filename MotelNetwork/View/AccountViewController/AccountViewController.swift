//
//  AccountViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/9/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwipeBack

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var btnNewPost: UIButton!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnLogOut: UIButton!
    @IBOutlet weak var tbAccountOptionList: UITableView!
    
    var dbReference: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tbAccountOptionList.delegate = self
        tbAccountOptionList.dataSource = self
        tbAccountOptionList.register(UINib(nibName: "AccountOptionTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountOptionTableViewCell")
        
        setUpView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
//        showLoading()
        tbAccountOptionList.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        stopLoading()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Set up view
    func setUpView() {
        
        let uid = Auth.auth().currentUser?.uid
        
        dbReference = Database.database().reference()
        dbReference.child("Users").child(uid!).observe(.value) { (snapshot) in
            
            // Get user value
            let value = snapshot.value as! NSDictionary
            let userName = value["FullName"] as? String ?? ""
            let profileImageUrl = value["ProfileImageUrl"] as? String ?? ""
            let email = value["Email"] as? String ?? ""
            
            self.lblFullName.text = userName
            self.lblEmail.text = email
            self.ivAvatar.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        makeImageViewRounded(imageView: ivAvatar)
        makeButtonRounded(button: btnLogOut)
    }
    
    
    
    //MARK: Logic for UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbAccountOptionList.dequeueReusableCell(withIdentifier: "AccountOptionTableViewCell") as! AccountOptionTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.lblOption.text = "Đổi email"
        case 1:
            cell.lblOption.text = "Đổi mật khẩu"
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = ChangeEmailViewController()
            (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = ChangePasswordViewController()
            (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnLogOutPressed(_ sender: Any) {
        
        showAlertConfirmLogOut()
    }
    
    @IBAction func btnNewPostPressed(_ sender: Any) {
        
        
    }
}
