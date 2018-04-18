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
//import TwicketSegmentedControl

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NVActivityIndicatorViewable {
    
    @IBOutlet weak var vTest: UIView!
    @IBOutlet weak var tbMostView: UITableView!
    @IBOutlet weak var tbNearMe: UITableView!
    @IBOutlet weak var tbListNews: UITableView!
    @IBOutlet weak var btnNews: UIButton!
    @IBOutlet weak var btnMostView: UIButton!
    @IBOutlet weak var btnNearMe: UIButton!
    @IBOutlet weak var vNewsProgress: UIView!
    @IBOutlet weak var vMostViewProgress: UIView!
    @IBOutlet weak var vNearMeProgress: UIView!
    @IBOutlet weak var sclContent: UIScrollView!
    @IBOutlet weak var vNews: UIView!
    @IBOutlet weak var vMostView: UIView!
    @IBOutlet weak var vNearMe: UIView!

    
    var screenWidth = UIScreen.main.bounds.width
    var listNews = [News]()
    var listMostView = [News]()
    var listNearMe = [News]()
    var refreshControl0: UIRefreshControl = UIRefreshControl()
    var refreshControl1: UIRefreshControl = UIRefreshControl()
    var refreshControl2: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sclContent.delegate = self
        
        // tbListNew
        tbListNews.delegate = self
        tbListNews.dataSource = self
        tbListNews.register(UINib(nibName: "ListNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListNewsTableViewCell")
        
        // tbMostView
        tbMostView.delegate = self
        tbMostView.dataSource = self
        tbMostView.register(UINib(nibName: "ListNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListNewsTableViewCell")
        
        // tbNearMe
        tbNearMe.delegate = self
        tbNearMe.dataSource = self
        tbNearMe.register(UINib(nibName: "ListNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListNewsTableViewCell")
        
//        let titles = ["Tin mới", "Xem nhiều", "Gần tôi"]
//        let frame = CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: 40)
//        
//        let segmentedControl = TwicketSegmentedControl(frame: frame)
//        segmentedControl.topAnchor.constraint(equalTo: view.topAnchor)
//        segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor)
//        segmentedControl.leadingAnchor.constraint(equalTo: view.trailingAnchor)
//        segmentedControl.setSegmentItems(titles)
//        segmentedControl.delegate = self
//        
//        view.addSubview(segmentedControl)
        
        loadDataNews()
        loadDataMostView()
        loadDataNearMe()
        setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tbListNews.reloadData()
        tbNearMe.reloadData()
        tbMostView.reloadData()
    }
    
    //MARK: Refresh data
    
    @objc func refreshDataNews() {
        
        listNews.removeAll()
        loadDataNews()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            self.refreshControl0.endRefreshing()
        }
    }
    
    @objc func refreshDataMostView() {
        
        listMostView.removeAll()
        loadDataMostView()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            self.refreshControl1.endRefreshing()
        }
    }
    
    @objc func refreshDataNearMe() {
        
        listNearMe.removeAll()
        loadDataNearMe()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            self.refreshControl2.endRefreshing()
        }
    }
    
    //MARK: Set up views
    
    func setUpViewNews() {
        
        setColorAndFontButton(buttonEnable: btnNews, buttonDisable1: btnMostView, buttonDisable2: btnNearMe)
        setViewState(enabledView: vNewsProgress, disabledView2: vMostViewProgress, disabledView3: vNearMeProgress)
        tbListNews.reloadData()
        tbListNews.scrollTableViewToTop(animated: true)
        
        self.sclContent.setContentOffset(CGPoint(x: Double(0), y: 0), animated: true)
        
        // Add refresh control
        refreshControl0.addTarget(self, action: #selector(self.refreshDataNews), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
                
            tbListNews.refreshControl = refreshControl0
        }
        else {
            tbListNews.addSubview(refreshControl0)
        }
    }
    
    func setUpViewMostView() {

        setColorAndFontButton(buttonEnable: btnMostView, buttonDisable1: btnNearMe, buttonDisable2: btnNews)
        setViewState(enabledView: vMostViewProgress, disabledView2: vNewsProgress, disabledView3: vNearMeProgress)
        tbMostView.reloadData()
        tbMostView.scrollTableViewToTop(animated: true)
        
        self.sclContent.setContentOffset(CGPoint(x: Double(screenWidth), y: 0), animated: true)
        
         refreshControl1.addTarget(self, action: #selector(self.refreshDataMostView), for: UIControlEvents.valueChanged)

        if #available(iOS 10.0, *) {
    
            tbMostView.refreshControl = refreshControl1
        }
        else {
        
            tbMostView.addSubview(refreshControl1)
        }
    }
    
    func setUpViewNearMe() {

        
        setColorAndFontButton(buttonEnable: btnNearMe, buttonDisable1: btnMostView, buttonDisable2: btnNews)
        setViewState(enabledView: vNearMeProgress, disabledView2: vMostViewProgress, disabledView3: vNewsProgress)
        tbNearMe.reloadData()
        tbNearMe.scrollTableViewToTop(animated: true)
        
        self.sclContent.setContentOffset(CGPoint(x: Double(screenWidth * 2), y: 0), animated: true)
        
        refreshControl2.addTarget(self, action: #selector(self.refreshDataNearMe), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            
            tbNearMe.refreshControl = refreshControl2
        }
        else {
            
            tbNearMe.addSubview(refreshControl2)
        }
    }
    
    // MARK: Set up view
    
    func setUpView() {
        setViewState(enabledView: vNewsProgress, disabledView2: vNearMeProgress, disabledView3: vMostViewProgress)
        setColorAndFontButton(buttonEnable: btnNews, buttonDisable1: btnNearMe, buttonDisable2: btnMostView)
        self.tapToDismissKeyboard()
    }
    
    //MARK: Database interaction
    
    func loadDataNews() {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let recentPostQuery = ref.child("Posts").child(uid!).child("MyPosts").queryLimited(toFirst: 100)
//        let recentPostQuery = ref.child("Posts").queryLimited(toFirst: 100)
        recentPostQuery.observe(.childAdded, with: { (snapshot) in
            
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
                news.user = dictionary["user"] as? String
                news.postImageUrl0 = dictionary["postImageUrl0"] as? String
                news.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String
                news.postDate = dictionary["postDate"] as? String
                
                self.listNews.append(news)
                self.tbListNews.reloadData()
            }
        }, withCancel: nil)
    }
    
    func loadDataMostView() {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let mostViewQuery = ref.child("Posts").child(uid!).child("MyPosts").queryOrdered(byChild: "price")
        mostViewQuery.observe(.childAdded, with: { (snapshot) in
            
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
                news.user = dictionary["user"] as? String
                news.postImageUrl0 = dictionary["postImageUrl0"] as? String
                news.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String
                news.postDate = dictionary["postDate"] as? String
                
                self.listMostView.append(news)
                self.tbMostView.reloadData()
            }
        }, withCancel: nil)
    }
    
    func loadDataNearMe() {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let nearMeQuery = ref.child("Posts").child(uid!).child("MyPosts").queryOrdered(byChild: "district")
        nearMeQuery.observe(.childAdded, with: { (snapshot) in
            
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
                news.user = dictionary["user"] as? String
                news.postImageUrl0 = dictionary["postImageUrl0"] as? String
                news.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String
                news.postDate = dictionary["postDate"] as? String
                
                self.listNearMe.append(news)
                self.tbNearMe.reloadData()
            }
        }, withCancel: nil)
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnNewClick(_ sender: Any) {
        
        setUpViewNews()
    }
    
    @IBAction func btnMostViewClick(_ sender: Any) {
        
        setUpViewMostView()
    }
    
    @IBAction func btnNearMeClick(_ sender: Any) {
        
        setUpViewNearMe()
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
        
        if tableView == tbListNews {
            return listNews.count
        } else if tableView == tbMostView {
            return listMostView.count
        } else if tableView == tbNearMe {
            return listNearMe.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbListNews.dequeueReusableCell(withIdentifier: "ListNewsTableViewCell") as! ListNewsTableViewCell
        if tableView == tbListNews {
            let news = listNews[indexPath.row]
            cell.populateData(news: news)
            
        }
        if tableView == tbMostView {
            let mostView = listMostView[indexPath.row]
            cell.populateData(news: mostView)
        }
        
        if tableView == tbNearMe {
            let nearMe = listNearMe[indexPath.row]
            cell.populateData(news: nearMe)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailNewsViewController()
        
        
        if tableView == tbListNews {
            
            let news = listNews[indexPath.row]
            vc.currentNews = news
            (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
        }
        
        if tableView == tbMostView {
            
            let news = listMostView[indexPath.row]
            vc.currentNews = news
            (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
        }
        
        if tableView == tbNearMe {
            
            let news = listNearMe[indexPath.row]
            vc.currentNews = news
            (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: Scroll view did scroll
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //        let contentOffsetX = scrollView.contentOffset.x
        //        var currentPage = contentOffsetX / screenWidth
        if sclContent.contentOffset.x >= 0 &&  sclContent.contentOffset.x < screenWidth {
            
            // News
            setColorAndFontButton(buttonEnable: btnNews, buttonDisable1: btnMostView, buttonDisable2: btnNearMe)
            setViewState(enabledView: vNewsProgress, disabledView2: vMostViewProgress, disabledView3: vNearMeProgress)
        }
        else if sclContent.contentOffset.x >= screenWidth && sclContent.contentOffset.x < 2 * screenWidth  {
            
            // Most View
            setColorAndFontButton(buttonEnable: btnMostView, buttonDisable1: btnNearMe, buttonDisable2: btnNews)
            setViewState(enabledView: vMostViewProgress, disabledView2: vNewsProgress, disabledView3: vNearMeProgress)
        }
        else {
            
            // Near Me
            setColorAndFontButton(buttonEnable: btnNearMe, buttonDisable1: btnMostView, buttonDisable2: btnNews)
            setViewState(enabledView: vNearMeProgress, disabledView2: vMostViewProgress, disabledView3: vNewsProgress)
        }
    }

    
//    func didSelect(_ segmentIndex: Int) {
//        print("Selected index: \(segmentIndex)")
//        switch segmentIndex {
//        case 0:
//            setUpViewNews()
//        case 1:
//            setUpViewMostView()
//        case 2:
//            setUpViewNearMe()
//        default:
//            setUpViewNews()
//        }
//
//    }
}

