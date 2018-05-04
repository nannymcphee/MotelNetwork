//
//  SearchViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/26/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import TBDropdownMenu

class SearchViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tbSearchResults: UITableView!
    
    var listNews = [News]()
    var listNewsFiltered = [News]()
    var listNewsFiltered2 = [News]()
    var isSearching: Bool = false
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
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
        listNewsFiltered2.removeAll()
        loadData()
        tbSearchResults.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set up view
    
    func setUpView() {
        
        // Add refresh control
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            tbSearchResults.refreshControl = refreshControl
        }
        else {
            tbSearchResults.addSubview(refreshControl)
        }
        
        tapToDismissKeyboard()
    }
    
    @objc func refreshData() {
        
        listNews.removeAll()
        listNewsFiltered.removeAll()
        listNewsFiltered2.removeAll()
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
                news.usersAllowed = dictionary["usersAllowed"] as? String
                news.timestamp = dictionary["timestamp"] as? Int
                news.views = dictionary["views"] as? Int
                
                self.listNews.append(news)
                self.listNewsFiltered2 = self.listNews.filter({ (news0) -> Bool in
                    return Int(news0.area!)! <= 20
                })
                
                self.tbSearchResults.reloadData()
            }
        }, withCancel: nil)
    }
    
    @IBAction func btnViewMapPressed(_ sender: Any) {
        
        let vc = GoogleMapViewController()
            
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnFilterPressed(_ sender: Any) {
        
        // Show dropdown menu
        let area1 = DropdownItem(title: "Dưới 20m2")
        let area2 = DropdownItem(title: "Từ 20-30m2")
        let area3 = DropdownItem(title: "Trên 30m2")
        let price1 = DropdownItem(title: "Dưới 3 triệu")
        let price2 = DropdownItem(title: "Từ 3-5 triệu")
        let price3 = DropdownItem(title: "Trên 5 triệu")
        let users1 = DropdownItem(title: "Dưới 3 người")
        let users2 = DropdownItem(title: "Từ 3-5 người")
        let users3 = DropdownItem(title: "Trên 5 người")
        let sectionArea = DropdownSection(sectionIdentifier: "Diện tích", items: [area1, area2, area3])
        let sectionPrice = DropdownSection(sectionIdentifier: "Giá", items: [price1, price2, price3])
        let sectionUsers = DropdownSection(sectionIdentifier: "Số người cho phép", items: [users1, users2, users3])
        let menuView = DropdownMenu(navigationController: navigationController!, sections: [sectionArea, sectionPrice, sectionUsers], selectedIndexPath: selectedIndexPath)
        
        menuView.topOffsetY = 83
        menuView.delegate = self
        menuView.showMenu()
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
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
                let title = news.title
                
                return (district?.lowercased().contains(searchText.lowercased()))! ||  (title?.lowercased().contains(searchText.lowercased()))!
            })
            
            listNewsFiltered = listNewsFiltered.sorted(by: { (news0, news1) -> Bool in
                return Int(news0.price!) < Int(news1.price!)
            })
            
            tbSearchResults.reloadData()
        }
    }
}

extension SearchViewController: DropdownMenuDelegate {
    
    func sortListNewsByAreaAsc() {
        self.listNewsFiltered2 = self.listNewsFiltered2.sorted(by: { (news0, news1) -> Bool in
            return news0.area?.localizedStandardCompare(news1.area!) == .orderedAscending
        })
    }
    
    func sortListNewsByPriceAsc() {
        self.listNewsFiltered2 = self.listNewsFiltered2.sorted(by: { (news0, news1) -> Bool in
            return Int(news0.price!) < Int(news1.price!)
        })
    }
    
    func sortListNewsByUsersAllowedAsc() {
        self.listNewsFiltered2 = self.listNewsFiltered2.sorted(by: { (news0, news1) -> Bool in
            return Int(news0.usersAllowed!)! < Int(news1.usersAllowed!)!
        })
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndexPath = indexPath
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                
                self.listNewsFiltered2 = self.listNews.filter({ (news0) -> Bool in
                    return Int(news0.area!)! <= 20
                })
                
                sortListNewsByAreaAsc()
                tbSearchResults.reloadData()
                
                if !(listNewsFiltered2.isEmpty) {
                    tbSearchResults.scrollTableViewToTop(animated: true)
                }
            }
            else if indexPath.row == 1 {
                
                self.listNewsFiltered2 = self.listNews.filter({ (news0) -> Bool in
                    return Int(news0.area!)! >= 20 && Int(news0.area!)! <= 30
                })
                
                sortListNewsByAreaAsc()
                tbSearchResults.reloadData()
                
                if !(listNewsFiltered2.isEmpty) {
                    tbSearchResults.scrollTableViewToTop(animated: true)
                }
            }
            else {
                
                self.listNewsFiltered2 = self.listNews.filter({ (news0) -> Bool in
                    return Int(news0.area!)! > 30
                })
                
                sortListNewsByAreaAsc()
                tbSearchResults.reloadData()
                
                if !(listNewsFiltered2.isEmpty) {
                    tbSearchResults.scrollTableViewToTop(animated: true)
                }
            }
        case 1:
            if indexPath.row == 0 {
                
                self.listNewsFiltered2 = self.listNews.filter({ (news0) -> Bool in
                    return Int(news0.price!) < 3000000
                })
                
                sortListNewsByPriceAsc()
                tbSearchResults.reloadData()
                
                if !(listNewsFiltered2.isEmpty) {
                    tbSearchResults.scrollTableViewToTop(animated: true)
                }
            }
            else if indexPath.row == 1 {
                
                self.listNewsFiltered2 = self.listNews.filter({ (news0) -> Bool in
                    return Int(news0.price!) >= 3000000 && Int(news0.price!) <= 5000000
                })
                
                sortListNewsByPriceAsc()
                tbSearchResults.reloadData()
                
                if !(listNewsFiltered2.isEmpty) {
                    tbSearchResults.scrollTableViewToTop(animated: true)
                }
            }
            else {
                
                self.listNewsFiltered2 = self.listNews.filter({ (news0) -> Bool in
                    return Int(news0.price!) > 5000000
                })
                
                sortListNewsByPriceAsc()
                tbSearchResults.reloadData()
                
                if !(listNewsFiltered2.isEmpty) {
                    tbSearchResults.scrollTableViewToTop(animated: true)
                }
            }
        case 2:
            if indexPath.row == 0 {
                
                self.listNewsFiltered2 = self.listNews.filter({ (news0) -> Bool in
                    return Int(news0.usersAllowed!)! < 3
                })
                
                sortListNewsByUsersAllowedAsc()
                tbSearchResults.reloadData()
                
                if !(listNewsFiltered2.isEmpty) {
                    tbSearchResults.scrollTableViewToTop(animated: true)
                }            }
            else if indexPath.row == 1 {
                
                self.listNewsFiltered2 = self.listNews.filter({ (news0) -> Bool in
                    return Int(news0.usersAllowed!)! >= 3 && Int(news0.usersAllowed!)! <= 5
                })
                
                sortListNewsByUsersAllowedAsc()
                tbSearchResults.reloadData()
                
                if !(listNewsFiltered2.isEmpty) {
                    tbSearchResults.scrollTableViewToTop(animated: true)
                }
            }
            else {
                
                self.listNewsFiltered2 = self.listNews.filter({ (news0) -> Bool in
                    return Int(news0.usersAllowed!)! > 5
                })
                
                sortListNewsByUsersAllowedAsc()
                tbSearchResults.reloadData()
                
                if !(listNewsFiltered2.isEmpty) {
                    tbSearchResults.scrollTableViewToTop(animated: true)
                }
            }
        default:
            break
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListNewsTableViewCell", for: indexPath) as! ListNewsTableViewCell
        var news = News()
        
        if isSearching {
            
            news = listNewsFiltered[indexPath.row]
        }
        else {
            
            news = self.listNewsFiltered2[indexPath.row]
        }
        
        cell.populateData(news: news)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if isSearching {
            return listNewsFiltered.count
        }
        
        return self.listNewsFiltered2.count
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
            
            increaseViewForPost(reference: ref)
            vc.currentNews = news
        }
        else {
            
            news = self.listNewsFiltered2[indexPath.row]
            
            let postID = news.id
            let ref = Database.database().reference().child("Posts").child(postID!).child("views")
            
            increaseViewForPost(reference: ref)
            vc.currentNews = news
        }
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
}
