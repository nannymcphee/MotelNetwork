//
//  SavedNewsViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 5/31/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwipeBack
import Kingfisher
import ObjectMapper

class SavedNewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblSavedPostCount: UILabel!
    @IBOutlet weak var tbSavedPost: UITableView!
    
    var listNews = [News]()
    var newsCount : Int = 0
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var postIdArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tbSavedPost.delegate = self
        tbSavedPost.dataSource = self
        tbSavedPost.register(UINib(nibName: "ListNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListNewsTableViewCell")
        tbSavedPost.reloadData()
        
        loadData2()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tbSavedPost.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refreshData() {
        
        listNews.removeAll()
        loadData2()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            self.refreshControl.endRefreshing()
        }
    }
    
    //MARK: Set up view
    func setUpView() {
        
        // Add refresh control
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            tbSavedPost.refreshControl = refreshControl
        }
        else {
            tbSavedPost.addSubview(refreshControl)
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            return
        }
        
        let reference = Database.database().reference().child("Users").child(uid)
        reference.observe(.value) { (snapshot) in
            
            // Get user value
            let value = snapshot.value as! NSDictionary
            let userName = value["FullName"] as? String ?? ""
            let profileImageUrl = value["ProfileImageUrl"] as? String ?? ""
            
            self.lblFullName.text = userName
            self.loadImageToImageView(imageUrl: profileImageUrl, imageView: self.ivAvatar)
        }
        
        makeImageViewRounded(imageView: ivAvatar)
    }
    
    //MARK: Database interaction
    
    func loadData2() {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let query = ref.child("SavedPosts").child(uid!)
        
        query.keepSynced(true)
        
        query.observe(.childAdded) { (snapshot) in
            if let json = snapshot.value as? [String: AnyObject] {
                var news = News()
                
                news = Mapper<News>().map(JSON: json) ?? News()
                
                self.listNews.append(news)
                self.newsCount = self.listNews.count
                
                DispatchQueue.main.async {
                    self.lblSavedPostCount.text = "Số tin đã lưu: \(self.newsCount)"
                    self.tbSavedPost.reloadData()
                }
            }
        }
    }
    
    func loadData() {
        
        self.postIdArray.removeAll()
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let query = ref.child("SavedPosts").child(uid!)
        
        query.keepSynced(true)
        query.observe(.childAdded, with: { (snapshot) in
            
            let id = snapshot.value as! String
            self.postIdArray.append(id)
            
            for id in self.postIdArray {
                ref.child("Posts").queryOrdered(byChild: "postID").queryEqual(toValue: id).observe(.childAdded) { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let news = News(dictionary: dictionary)
                        news.id = snapshot.key
                        
                        let priceStr = dictionary["price"] as? String
                        let waterPriceStr = dictionary["waterPrice"] as? String
                        let electricPriceStr = dictionary["electricPrice"] as? String
                        let internetPriceStr = dictionary["internetPrice"] as? String
                        
//                        news.price = Double(priceStr ?? "0.0")
//                        news.waterPrice = Double(waterPriceStr ?? "0.0")
//                        news.electricPrice = Double(electricPriceStr ?? "0.0")
//                        news.internetPrice = Double(internetPriceStr ?? "0.0")
                        
                        news.price = priceStr
                        news.waterPrice = waterPriceStr
                        news.electricPrice = electricPriceStr
                        news.internetPrice = internetPriceStr
                        news.area = dictionary["area"] as? String
                        news.district = dictionary["district"] as? String
                        news.title = dictionary["title"] as? String
                        news.address = dictionary["address"] as? String
                        news.description = dictionary["description"] as? String
                        news.phoneNumber = dictionary["phoneNumber"] as? String
                        news.ownerID = dictionary["ownerID"] as? String
                        news.usersAllowed = dictionary["usersAllowed"] as? String
                        news.timestamp = dictionary["timestamp"] as? Int
                        news.timestampEdit = dictionary["timestampEdit"] as? Int
                        news.postImageUrl0 = dictionary["postImageUrl0"] as? String
                        news.postImageUrl1 = dictionary["postImageUrl1"] as? String
                        news.postImageUrl2 = dictionary["postImageUrl2"] as? String
                        
                        DispatchQueue.main.async {
                            self.listNews.append(news)
                            self.listNews = self.listNews.sorted(by: { (news0, news1) -> Bool in
                                return news0.timestamp! > (news1.timestamp!)
                            })
                            self.newsCount = self.listNews.count
                            self.lblSavedPostCount.text = "Đã lưu: \(self.newsCount)"
                            self.tbSavedPost.reloadData()
                        }
                        
                    }
                }
            }
        }, withCancel: nil)
        
       
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
}

extension SavedNewsViewController {
    
    //MARK: Logic for UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if listNews.isEmpty {
            
            tbSavedPost.showEmptyDataView(message: messageEmptyPost, image: #imageLiteral(resourceName: "icEmptyPost"))
        }
        else {
            
            tbSavedPost.backgroundView = nil
            
            return 1
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbSavedPost.dequeueReusableCell(withIdentifier: "ListNewsTableViewCell") as! ListNewsTableViewCell
        
        let news = listNews[indexPath.row]
        cell.populateData(news: news)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let news = listNews[indexPath.row]
        let vc = DetailNewsViewController()
        
        vc.currentNews = news
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = deleteAction(at: indexPath)
        let config = UISwipeActionsConfiguration(actions: [delete])
        
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
    // Swipe actions
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .destructive, title: "") { (action, view, nil) in
            
            // Query delete from database
            let news = self.listNews[indexPath.row]
            let newsID = news.id
            let uid = Auth.auth().currentUser?.uid
            let ref = Database.database().reference().child("SavedPosts").child(uid!).child(newsID!)

            // Show confirmation alert
            let alert = UIAlertController(title: messageConfirmDeleteRoom, message: nil, preferredStyle: .actionSheet)
            let actionDestroy = UIAlertAction(title: "Xóa", style: .destructive) { (action) in
                if news.postImageUrl0 == nil || news.postImageUrl1 == nil || news.postImageUrl2 == nil {
                    
                    self.showAlert(title: "Thông báo", alertMessage: "Vui lòng tải lại trang trước khi xóa phòng này")
                }
                else {
                    
                    self.tbSavedPost.beginUpdates()
                    self.deleteData(reference: ref)
                    self.listNews.remove(at: indexPath.row)
                    self.tbSavedPost.deleteRows(at: [indexPath], with: .automatic)
                    self.tbSavedPost.endUpdates()
                    self.tbSavedPost.reloadData()
                    self.newsCount = self.listNews.count
                    self.lblSavedPostCount.text = "Số tin đã lưu: \(self.newsCount)"
                }
            }
            
            let actionCancel = UIAlertAction(title: "Không", style: .cancel) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(actionDestroy)
            alert.addAction(actionCancel)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        action.image = #imageLiteral(resourceName: "icDelete")
        
        return action
    }
}
