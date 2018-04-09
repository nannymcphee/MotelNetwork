//
//  BeforeSignHomeViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/2/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth

class BeforeSignHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tbListNews: UITableView!
    @IBOutlet weak var sbSearch: UISearchBar! {
        didSet {
            sbSearch.changeTextFont(textFont: UIFont(name: "Helvetica Neue", size: 14))
        }
    }
    @IBOutlet weak var btnNews: UIButton!
    @IBOutlet weak var btnMostView: UIButton!
    @IBOutlet weak var btnNearMe: UIButton!
    @IBOutlet weak var vNewsProgress: UIView!
    @IBOutlet weak var vMostViewProgress: UIView!
    @IBOutlet weak var vNearMeProgress: UIView!
    
    
    var listNews = [Room]()
    var listMostView = [Room]()
    var listNearMe = [Room]()
    
    var isNew = true
    var isMostView = false
    var isNearMe = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vMostViewProgress.isHidden = true
        vNearMeProgress.isHidden = true
        
        
        loadData()
        
        tbListNews.delegate = self
        tbListNews.dataSource = self
        tbListNews.register(UINib(nibName: "ListNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListNewsTableViewCell")
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        //list new
        var room1 = Room(id: "1", name: "Phong 1", area: "20", price: 300000)
        var room2 = Room(id: "1", name: "Phong 2", area: "20", price: 300000)
        var room3 = Room(id: "1", name: "Phong 3", area: "20", price: 300000)
        var room4 = Room(id: "1", name: "Phong 4", area: "20", price: 300000)
        listNews.append(room1)
        listNews.append(room2)
        listNews.append(room3)
        listNews.append(room4)
        
        //list Mostview
        var room5 = Room(id: "1", name: "Phong 5", area: "20", price: 300000)
        var room6 = Room(id: "1", name: "Phong 6", area: "20", price: 300000)
        
        listMostView.append(room5)
        listMostView.append(room6)
        
        //list Near me
        var room7 = Room(id: "1", name: "Phong 7", area: "20", price: 300000)
        var room8 = Room(id: "1", name: "Phong 8", area: "20", price: 300000)
        
        listNearMe.append(room7)
        listNearMe.append(room8)
        
        
    }
    
    @IBAction func btnNewClick(_ sender: Any) {
        isNew = true
        isMostView = false
        isNearMe = false
        setColorAndFontButton(buttonEnable: btnNews, buttonDisable1: btnMostView, buttonDisable2: btnNearMe)
        
        vMostViewProgress.isHidden = true
        vNearMeProgress.isHidden = true
        vNewsProgress.isHidden = false
        tbListNews.reloadData()
    }
    
    @IBAction func btnMostViewClick(_ sender: Any) {
        isNew = false
        isMostView = true
        isNearMe = false
        setColorAndFontButton(buttonEnable: btnMostView, buttonDisable1: btnNearMe, buttonDisable2: btnNews)
        
        vNewsProgress.isHidden = true
        vNearMeProgress.isHidden = true
        vMostViewProgress.isHidden = false
        tbListNews.reloadData()
        
    }
    @IBAction func btnNearMeClick(_ sender: Any) {
        isNew = false
        isMostView = false
        isNearMe = true
        setColorAndFontButton(buttonEnable: btnNearMe, buttonDisable1: btnMostView, buttonDisable2: btnNews)
        vMostViewProgress.isHidden = true
        vNewsProgress.isHidden = true
        vNearMeProgress.isHidden = false
        tbListNews.reloadData()
    }
    
    func setColorAndFontButton(buttonEnable: UIButton, buttonDisable1: UIButton, buttonDisable2: UIButton) {
        
        let colorEnable = UIColor.black
        let colorDisable = UIColor.lightGray
        
        buttonEnable.setTitleColor(colorEnable, for: .normal)
        buttonEnable.titleLabel?.font = UIFont(name: "Helvetica Neue Bold", size: 12)
        buttonDisable1.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 12)
        buttonDisable2.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 12)
        buttonDisable1.setTitleColor(colorDisable, for: .normal)
        buttonDisable2.setTitleColor(colorDisable, for: .normal)
    }

    
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
            let room = listNews[indexPath.row]
            cell.populateData(room: room)
            
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
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    
}
