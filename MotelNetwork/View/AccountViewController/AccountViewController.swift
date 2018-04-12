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
    @IBOutlet weak var tbNews: UITableView!
    @IBOutlet weak var lblRoomsCount: UILabel!
    @IBOutlet weak var lblNewsCount: UILabel!
    var dbReference: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tbNews.delegate = self
        tbNews.dataSource = self
        tbNews.register(UINib(nibName: "ListNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListNewsTableViewCell")
        
        setUpView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
//        showLoading()
        tbNews.reloadData()
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
    }
    
    
    
    //MARK: Logic for UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbNews.dequeueReusableCell(withIdentifier: "ListNewsTableViewCell") as! ListNewsTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.lblArea.text = "25m2"
            cell.lblPrice.text = "2500000đ"
            cell.lblLocation.text = "Phú nhuận"
            cell.lblTitle.text = "Cho thuê nhà hẻm ô tô quận Phú Nhuận"
            cell.lblTitle.text = "Phòng 1"
        case 1:
            cell.lblArea.text = "45m2"
            cell.lblPrice.text = "3500000đ"
            cell.lblLocation.text = "Tân Phú"
            cell.lblTitle.text = "Cho thuê căn hộ chung cư cao cấp quận Tân Phú"
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = SignedInDetailNewsViewController()
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnNewPostPressed(_ sender: Any) {
    
        
    }
}
