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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbSearchResults.delegate = self
        tbSearchResults.dataSource = self
        tbSearchResults.register(UINib(nibName: "ListNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListNewsTableViewCell")
        
        searchBar.delegate = self
        searchBar.changeTextFont(textFont: UIFont(name: "Helvetica Neue", size: 12.0))
        searchBar.returnKeyType = .done
        
        fetchPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tbSearchResults.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Database interactions
    
    func fetchPosts() {
        
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
                news.postDate = dictionary["postDate"] as? String
                
                self.listNews.append(news)
                self.tbSearchResults.insertRows(at: [IndexPath(row: self.listNews.count - 1, section: 0)], with: .automatic)
                
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
                
                return (district?.lowercased().contains(searchText.lowercased()))!
            })
            
            tbSearchResults.reloadData()
        }
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
        return 145
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = DetailNewsViewController()
        var news = News()

        if isSearching {
            
            news = listNewsFiltered[indexPath.row]
            vc.currentNews = news
        }
        else {
            
            news = self.listNews[indexPath.row]
            vc.currentNews = news
        }
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
}
