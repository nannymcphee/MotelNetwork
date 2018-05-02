//
//  SearchViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/26/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tbSearchResults: UITableView!
    
    var listNews = [News]()
    var listNewsFiltered = [News]()
    var isSearching: Bool = false
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbSearchResults.delegate = self
        tbSearchResults.dataSource = self
        tbSearchResults.register(UINib(nibName: "ListNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListNewsTableViewCell")
        tbSearchResults.reloadData()
        
        searchBar.delegate = self
        searchBar.changeTextFont(textFont: UIFont(name: "Helvetica Neue", size: 12.0))
        searchBar.returnKeyType = .done
        
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        listNews.removeAll()
        listNewsFiltered.removeAll()
        loadData()
        tbSearchResults.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView() {
        
        tapToDismissKeyboard()
        // Add refresh control
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            tbSearchResults.refreshControl = refreshControl
        }
        else {
            tbSearchResults.addSubview(refreshControl)
        }
    }
    
    @objc func refreshData() {
        
        listNews.removeAll()
        listNewsFiltered.removeAll()
        loadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            self.refreshControl.endRefreshing()
        }
    }
    
    //MARK: Database interactions
    
    func loadData() {
        
        let ref = Database.database().reference().child("Posts")
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
                news.timestamp = dictionary["timestamp"] as? Int
                news.views = dictionary["views"] as? Int
                
                self.listNews.append(news)
                self.listNews = self.listNews.sorted(by: { (news0, news1) -> Bool in

                    return Int(news0.price!) < Int(news1.price!)
                })
                
                self.tbSearchResults.reloadData()
            }
        }, withCancel: nil)
    }
    
    //MARK: Logic for SearchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchBar.text?.isEmpty)! {
            
            isSearching = false
            view.endEditing(true)
            tbSearchResults.reloadData()
        }
        else {
            
            isSearching = true
            listNewsFiltered = self.listNews.filter({ (news) -> Bool in
                
                let district = news.district
                let area = news.area
                let title = news.title
                
                return (district?.lowercased().contains(searchText.lowercased()))! || (area?.lowercased().contains(searchText.lowercased()))! || (title?.lowercased().contains(searchText.lowercased()))!
            })
            
            tbSearchResults.reloadData()
        }
    }
    
    
    @IBAction func btnViewMapPressed(_ sender: Any) {
        
        let vc = GoogleMapViewController()
            
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SearchViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListNewsTableViewCell", for: indexPath) as! ListNewsTableViewCell
        var news = News()
        
        if isSearching {
            
            news = listNewsFiltered[indexPath.row]
        }
        else {
            
            news = self.listNews[indexPath.row]
        }
        
        cell.populateData(news: news)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if isSearching {
            return listNewsFiltered.count
        }
        
        return self.listNews.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = DetailNewsViewController()
        var news = News()

        if isSearching {
            
            news = listNewsFiltered[indexPath.row]
            
            let postID = news.id
            let ref = Database.database().reference().child("Posts").child(postID!).child("views")
            
            ref.runTransactionBlock { (currentData: MutableData!) -> TransactionResult in
                var value = currentData.value as? Int
                
                if value == nil {
                    value = 0
                }
                
                currentData.value = value! + 1
                
                return TransactionResult.success(withValue: currentData)
            }
            
            vc.currentNews = news
        }
        else {
            
            news = self.listNews[indexPath.row]
            
            let postID = news.id
            let ref = Database.database().reference().child("Posts").child(postID!).child("views")
            
            ref.runTransactionBlock { (currentData: MutableData!) -> TransactionResult in
                var value = currentData.value as? Int
                
                if value == nil {
                    value = 0
                }
                
                currentData.value = value! + 1
                
                return TransactionResult.success(withValue: currentData)
            }
            
            vc.currentNews = news
        }
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
}
