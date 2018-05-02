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
import Kingfisher

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var btnNewPost: UIButton!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var tbNews: UITableView!
    @IBOutlet weak var lblNewsCount: UILabel!
    
    var dbReference: DatabaseReference!
    var listNews = [News]()
    var newsCount : Int = 0
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tbNews.delegate = self
        tbNews.dataSource = self
        tbNews.register(UINib(nibName: "ListNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListNewsTableViewCell")
        tbNews.reloadData()
        
        loadData()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tbNews.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refreshData() {
        
        listNews.removeAll()
        loadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            self.refreshControl.endRefreshing()
        }
    }
    
    //MARK: Set up view
    func setUpView() {
        
        // Add refresh control
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            tbNews.refreshControl = refreshControl
        }
        else {
            tbNews.addSubview(refreshControl)
        }
                
        guard let uid = Auth.auth().currentUser?.uid else {
            
            return
        }
        
        dbReference = Database.database().reference()
        dbReference.child("Users").child(uid).observe(.value) { (snapshot) in
            
            // Get user value
            let value = snapshot.value as! NSDictionary
            let userName = value["FullName"] as? String ?? ""
            let profileImageUrl = value["ProfileImageUrl"] as? String ?? ""
            
            self.lblFullName.text = userName
            let resource = ImageResource(downloadURL: URL(string: profileImageUrl)!)
            self.ivAvatar.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "defaultAvatar"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        
        makeImageViewRounded(imageView: ivAvatar)
    }
    
    //MARK: Database interaction
    
    // Load newest posts
    func loadData() {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let myRecentPostQuery = ref.child("Posts").queryOrdered(byChild: "ownerID").queryEqual(toValue: uid).queryLimited(toFirst: 100)
        
        myRecentPostQuery.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let news = News(dictionary: dictionary)
                news.id = snapshot.key
  
                
                DispatchQueue.main.async {
                    self.reloadInputViews()
                }
                
                let priceStr = dictionary["price"] as? String
                let waterPriceStr = dictionary["waterPrice"] as? String
                let electricPriceStr = dictionary["electricPrice"] as? String
                let internetPriceStr = dictionary["internetPrice"] as? String
        
                news.price = Double(priceStr ?? "0.0")
                news.waterPrice = Double(waterPriceStr ?? "0.0")
                news.electricPrice = Double(electricPriceStr ?? "0.0")
                news.internetPrice = Double(internetPriceStr ?? "0.0")
                news.area = dictionary["area"] as? String
                news.district = dictionary["district"] as? String
                news.title = dictionary["title"] as? String
                news.address = dictionary["address"] as? String
                news.description = dictionary["description"] as? String
                news.phoneNumber = dictionary["phoneNumber"] as? String
                news.ownerID = dictionary["ownerID"] as? String
                news.postImageUrl0 = dictionary["postImageUrl0"] as? String
                news.postImageUrl1 = dictionary["postImageUrl1"] as? String
                news.postImageUrl2 = dictionary["postImageUrl2"] as? String
                news.usersAllowed = dictionary["usersAllowed"] as? String
                news.timestamp = dictionary["timestamp"] as? Int
                
                self.listNews.append(news)
                self.listNews = self.listNews.sorted(by: { (news0, news1) -> Bool in
                    return news0.timestamp! > (news1.timestamp!)
                })
                self.newsCount = self.listNews.count
                self.lblNewsCount.text = "\(self.newsCount)"
                self.tbNews.reloadData()
            }
        }, withCancel: nil)
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnNewPostPressed(_ sender: Any) {
    
        let vc = NewPostViewController()
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension AccountViewController {
    
    //MARK: Logic for UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbNews.dequeueReusableCell(withIdentifier: "ListNewsTableViewCell") as! ListNewsTableViewCell
        
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
        
        let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
    // Swipe actions
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let news = listNews[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "") { (action, view, nil) in
            
            let vc = EditPostViewController()
            vc.currentNews = news
            (UIApplication.shared.delegate as? AppDelegate)?.navigationController?.pushViewController(vc, animated: true)
        }
        
        action.image = #imageLiteral(resourceName: "icEdit")
        action.backgroundColor = UIColor(red: 34/255, green: 119/255, blue: 233/255, alpha: 1.0)
        
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .destructive, title: "") { (action, view, nil) in
            
            // Query delete from database
            let news = self.listNews[indexPath.row]
            let newsID = news.id
            let ref = Database.database().reference().child("Posts").child(newsID!)
            
            // Show confirmation alert
            let alert = UIAlertController(title: messageConfirmDeletePost, message: nil, preferredStyle: .actionSheet)
            let actionDestroy = UIAlertAction(title: "Xóa", style: .destructive) { (action) in
                self.deleteData(reference: ref)
                self.listNews.remove(at: indexPath.row)
                self.tbNews.deleteRows(at: [indexPath], with: .automatic)
                self.tbNews.reloadData()
                self.newsCount = self.listNews.count
                self.lblNewsCount.text = "\(self.newsCount)"
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

