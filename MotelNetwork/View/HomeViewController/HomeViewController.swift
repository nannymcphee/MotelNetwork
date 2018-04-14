//
//  BeforeSignHomeViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/2/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwipeBack
import NVActivityIndicatorView

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NVActivityIndicatorViewable {
    

    @IBOutlet weak var tbListNews: UITableView!
    @IBOutlet weak var btnNews: UIButton!
    @IBOutlet weak var btnMostView: UIButton!
    @IBOutlet weak var btnNearMe: UIButton!
    @IBOutlet weak var vNewsProgress: UIView!
    @IBOutlet weak var vMostViewProgress: UIView!
    @IBOutlet weak var vNearMeProgress: UIView!
    
    
    var listNews = [News]()
    var listMostView = [Room]()
    var listNearMe = [Room]()
    
    var isNew = true
    var isMostView = false
    var isNearMe = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        setUpView()
        
        tbListNews.delegate = self
        tbListNews.dataSource = self
        tbListNews.register(UINib(nibName: "ListNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListNewsTableViewCell")
    
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tbListNews.reloadData()
    }

    
    func setUpView() {
        setViewState(enabledView: vNewsProgress, disabledView2: vNearMeProgress, disabledView3: vMostViewProgress)
        setColorAndFontButton(buttonEnable: btnNews, buttonDisable1: btnNearMe, buttonDisable2: btnMostView)
        self.tapToDismissKeyboard()
        
    }
    
    //MARK: Database interaction
    
    func loadData() {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let recentPostQuery = ref.child("Posts").child(uid!).child("MyPosts").queryLimited(toFirst: 100)
        
        recentPostQuery.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let news = News(dictionary: dictionary)
                news.id = snapshot.key
                self.listNews.append(news)
                
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
                news.user = dictionary["user"] as? String
                news.postImageUrl0 = dictionary["postImageUrl0"] as? String
                news.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String
                news.postDate = dictionary["postDate"] as? String
            }
        }, withCancel: nil)
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnNewClick(_ sender: Any) {
        
        isNew = true
        isMostView = false
        isNearMe = false
        
        setColorAndFontButton(buttonEnable: btnNews, buttonDisable1: btnMostView, buttonDisable2: btnNearMe)
        setViewState(enabledView: vNewsProgress, disabledView2: vMostViewProgress, disabledView3: vNearMeProgress)
        tbListNews.reloadData()
        tbListNews.scrollTableViewToTop(animated: true)
    }
    
    @IBAction func btnMostViewClick(_ sender: Any) {
        
        isNew = false
        isMostView = true
        isNearMe = false
        
        setColorAndFontButton(buttonEnable: btnMostView, buttonDisable1: btnNearMe, buttonDisable2: btnNews)
        setViewState(enabledView: vMostViewProgress, disabledView2: vNewsProgress, disabledView3: vNearMeProgress)
        tbListNews.reloadData()
        tbListNews.scrollTableViewToTop(animated: true)
    }
    
    @IBAction func btnNearMeClick(_ sender: Any) {
        
        isNew = false
        isMostView = false
        isNearMe = true
        
        setColorAndFontButton(buttonEnable: btnNearMe, buttonDisable1: btnMostView, buttonDisable2: btnNews)
        setViewState(enabledView: vNearMeProgress, disabledView2: vMostViewProgress, disabledView3: vNewsProgress)
        tbListNews.reloadData()
        tbListNews.scrollTableViewToTop(animated: true)
    }
    
    //MARK: Exstension func
    
    func setViewState(enabledView: UIView, disabledView2: UIView, disabledView3: UIView) {
        
        enabledView.isHidden = false
        disabledView2.isHidden = true
        disabledView3.isHidden = true
    }
    
    func setColorAndFontButton(buttonEnable: UIButton, buttonDisable1: UIButton, buttonDisable2: UIButton) {
        
        let colorEnable = UIColor.init(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        let colorDisable = UIColor.lightGray
        
        buttonEnable.setTitleColor(colorEnable, for: .normal)
        buttonEnable.titleLabel?.font = UIFont(name: "Helvetica Neue-Bold", size: 12.0)
        buttonDisable1.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 12.0)
        buttonDisable2.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 12.0)
        buttonDisable1.setTitleColor(colorDisable, for: .normal)
        buttonDisable2.setTitleColor(colorDisable, for: .normal)
    }
    


    //MARK: Logic for table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isNew {
            return listNews.count
        }
        if isMostView {
            return listMostView.count
        }
        if isNearMe {
            return listNearMe.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbListNews.dequeueReusableCell(withIdentifier: "ListNewsTableViewCell") as! ListNewsTableViewCell
        if isNew {
            let news = listNews[indexPath.row]
            cell.populateData(news: news)
            
        }
        if isMostView {
            let room = listMostView[indexPath.row]
            cell.populateData(room: room)
        }
        
        if isNearMe {
            let room = listNearMe[indexPath.row]
            cell.populateData(room: room)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailNewsViewController()
        let news = listNews[indexPath.row]
        
        vc.currentNews = news
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
