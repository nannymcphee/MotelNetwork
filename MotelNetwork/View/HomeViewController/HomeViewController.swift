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
import TwicketSegmentedControl


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NVActivityIndicatorViewable, TwicketSegmentedControlDelegate {
    
    
    @IBOutlet weak var vSegment: UIView!
    @IBOutlet weak var tbMostView: UITableView!
    @IBOutlet weak var tbNearMe: UITableView!
    @IBOutlet weak var tbListNews: UITableView!
    @IBOutlet weak var sclContent: UIScrollView!
    @IBOutlet weak var vNews: UIView!
    @IBOutlet weak var vMostView: UIView!
    @IBOutlet weak var vNearMe: UIView!

    
    var screenWidth = UIScreen.main.bounds.width
    var listNews = [News]()
    var listMostView = [News]()
    var listNearMe = [News]()
    var listNewsSortedByDate = [News]()
    var refreshControl0: UIRefreshControl = UIRefreshControl()
    var refreshControl1: UIRefreshControl = UIRefreshControl()
    var refreshControl2: UIRefreshControl = UIRefreshControl()
    var segmentedControl: TwicketSegmentedControl = TwicketSegmentedControl()

    
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
    
    //MARK: Set up TwicketSegmentedControl
    
    func setUpSegmentControl() {
        // Set up segment control
        let titles = ["Tin mới", "Xem nhiều", "Gần tôi"]
        let frame = CGRect(x: 20, y: 48, width: self.view.frame.width, height: 40)
        segmentedControl = TwicketSegmentedControl(frame: frame)
        self.view.addSubview(segmentedControl)
        segmentedControl.setSegmentItems(titles)
        segmentedControl.delegate = self
        segmentedControl.isSliderShadowHidden = true
        
        // Auto layout
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 48).isActive = true
        segmentedControl.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func didSelect(_ segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            setUpViewNews()
        case 1:
            setUpViewMostView()
        case 2:
            setUpViewNearMe()
        default:
            break
        }
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
    
    // MARK: Set up views
    
    func setUpView() {
        
        setUpSegmentControl()
        self.tapToDismissKeyboard()
        loadDataNews()
        loadDataMostView()
        loadDataNearMe()
        
        // Add refresh controls
        
        // tbListNews
        refreshControl0.addTarget(self, action: #selector(self.refreshDataNews), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            
            tbListNews.refreshControl = refreshControl0
        }
        else {
            tbListNews.addSubview(refreshControl0)
        }
        
        // tbMostView
        refreshControl1.addTarget(self, action: #selector(self.refreshDataMostView), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            
            tbMostView.refreshControl = refreshControl1
        }
        else {
            
            tbMostView.addSubview(refreshControl1)
        }
        
        // tbNearMe
        refreshControl2.addTarget(self, action: #selector(self.refreshDataNearMe), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            
            tbNearMe.refreshControl = refreshControl2
        }
        else {
            
            tbNearMe.addSubview(refreshControl2)
        }
        
    }
    
    func setUpViewNews() {
        
        tbListNews.scrollTableViewToTop(animated: true)
        
        self.sclContent.setContentOffset(CGPoint(x: Double(0), y: 0), animated: false)
    }
    
    func setUpViewMostView() {

        tbMostView.reloadData()
        tbMostView.scrollTableViewToTop(animated: true)
        
        self.sclContent.setContentOffset(CGPoint(x: Double(screenWidth), y: 0), animated: false)
    }
    
    func setUpViewNearMe() {
        
        tbNearMe.reloadData()
        tbNearMe.scrollTableViewToTop(animated: true)
        
        self.sclContent.setContentOffset(CGPoint(x: Double(screenWidth * 2), y: 0), animated: false)
    }
    
    //MARK: Database interaction
    
    func loadDataNews() {

        let ref = Database.database().reference().child("Posts").queryOrdered(byChild: "postDate")

        ref.observe(.childAdded, with: { (snapshot) in
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
                news.postDate = dictionary["postDate"] as? String

                self.listNews.append(news)
                self.listNewsSortedByDate = self.listNews.sorted(by: { (news0, news1) -> Bool in
                    return news0.postDate?.localizedStandardCompare(news1.postDate!) == ComparisonResult.orderedDescending
                })
                self.tbListNews.reloadData()
            }
        }, withCancel: nil)
    }
    
    func loadDataMostView() {
        
        let ref = Database.database().reference().child("Posts").queryOrdered(byChild: "price")
        
        ref.observe(.childAdded, with: { (snapshot) in
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
                news.postDate = dictionary["postDate"] as? String
                
                self.listMostView.append(news)
                self.tbMostView.reloadData()
            }
        }, withCancel: nil)
    }
    
    func loadDataNearMe() {
        
        let ref = Database.database().reference().child("Posts").queryOrdered(byChild: "district")
        
        ref.observe(.childAdded, with: { (snapshot) in
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
                news.postDate = dictionary["postDate"] as? String
                
                self.listNearMe.append(news)
                self.tbNearMe.reloadData()
            }
        }, withCancel: nil)
    }

    //MARK: Logic for table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tbListNews {
            
            return listNewsSortedByDate.count
        }
        else if tableView == tbMostView {
            
            return listMostView.count
        }
        else if tableView == tbNearMe {
            
            return listNearMe.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListNewsTableViewCell", for: indexPath) as! ListNewsTableViewCell
        
        if tableView == tbListNews {

            let news = listNewsSortedByDate[indexPath.row]
            cell.populateData(news: news)
        }
        else if tableView == tbMostView {
            
            let mostView = listMostView[indexPath.row]
            cell.populateData(news: mostView)
        }
        else if tableView == tbNearMe {
            
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
            
            let news = listNewsSortedByDate[indexPath.row]
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
            segmentedControl.move(to: 0)
        }
        else if sclContent.contentOffset.x >= screenWidth && sclContent.contentOffset.x < 2 * screenWidth  {
            
            // Most View
            segmentedControl.move(to: 1)
        }
        else if sclContent.contentOffset.x >= 2 * screenWidth {
            
            // Near Me
            segmentedControl.move(to: 2)
        }
    }

}

