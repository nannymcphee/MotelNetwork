//
//  BeforeSignHomeViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/2/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwipeBack
import NVActivityIndicatorView

class BeforeSignHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NVActivityIndicatorViewable {
    
    
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
        
        setUpView()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        swipeToPop_Root()
        tbListNews.reloadData()
    }

    
    func setUpView() {
        setViewState(enabledView: vNewsProgress, disabledView2: vNearMeProgress, disabledView3: vMostViewProgress)
        setColorAndFontButton(buttonEnable: btnNews, buttonDisable1: btnNearMe, buttonDisable2: btnMostView)
        self.tapToDismissKeyboard()
    }
    
    func loadData() {
        
        
        //list new
        let room1 = Room(id: "1", name: "Phòng 1", area: "25", roomImageUrl0: "", roomImageUrl1: "", roomImageUrl2: "", user: "Nguyễn Văn A", price: 3000000)
        let room2 = Room(id: "1", name: "Phòng 2", area: "25", roomImageUrl0: "", roomImageUrl1: "", roomImageUrl2: "", user: "Nguyễn Văn A", price: 3000000)
        let room3 = Room(id: "1", name: "Phòng 3", area: "25", roomImageUrl0: "", roomImageUrl1: "", roomImageUrl2: "", user: "Nguyễn Văn A", price: 3000000)
        let room4 = Room(id: "1", name: "Phòng 4", area: "25", roomImageUrl0: "", roomImageUrl1: "", roomImageUrl2: "", user: "Nguyễn Văn A", price: 3000000)
        listNews.append(room1)
        listNews.append(room2)
        listNews.append(room3)
        listNews.append(room4)
        
        //list Mostview
        let room5 = Room(id: "1", name: "Phòng 5", area: "25", roomImageUrl0: "", roomImageUrl1: "", roomImageUrl2: "", user: "Nguyễn Văn A", price: 3000000)
        let room6 = Room(id: "1", name: "Phòng 6", area: "25", roomImageUrl0: "", roomImageUrl1: "", roomImageUrl2: "", user: "Nguyễn Văn A", price: 3000000)

        listMostView.append(room5)
        listMostView.append(room6)
        
        //list Near me
        let room7 = Room(id: "1", name: "Phòng 7", area: "25", roomImageUrl0: "", roomImageUrl1: "", roomImageUrl2: "", user: "Nguyễn Văn A", price: 3000000)
        let room8 = Room(id: "1", name: "Phòng 8", area: "25", roomImageUrl0: "", roomImageUrl1: "", roomImageUrl2: "", user: "Nguyễn Văn A", price: 3000000)

        listNearMe.append(room7)
        listNearMe.append(room8)
        
        
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
        
        let colorEnable = UIColor.black
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
        let vc = SignedInDetailNewsViewController()
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
