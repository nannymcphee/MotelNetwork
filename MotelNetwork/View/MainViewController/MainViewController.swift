//
//  MainViewController.swift
//  MotelNetwork
//
//  Created by Nguyen Seven on 4/5/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import SwipeBack
import FirebaseAuth
import FirebaseDatabase

class MainViewController: UIViewController, UITabBarControllerDelegate {
    
    var listViewController = [UIViewController]()
    var tabbarController: UITabBarController = UITabBarController()
    
    var vcHomeScreen = HomeViewController()
    var vcRoomManager = RoomManagementViewController()
    var vcAccount = AccountViewController()
    var vcSetting = SettingViewController()
    var vcSearch = SearchViewController()
    var vcMyRooms = MyRoomsViewController()
    
    var isAppearWhenFirstCreateMerchant = false
    
    @IBOutlet weak var vContent: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    func setupTabbar(homeScreenVC: UIViewController, searchVC: UIViewController, myRoomVC: UIViewController, myAccountVC: UIViewController, settingVC: UIViewController) {
       
        listViewController.removeAll()
        
        self.tabbarController.delegate = self
        
        let homeScreenVC = homeScreenVC
//        let viewHomeScreen = homeScreenVC.view
        homeScreenVC.tabBarItem = UITabBarItem(title: "Bảng tin", image: #imageLiteral(resourceName: "icNewsFeedNormal"), tag: 0)
        homeScreenVC.tabBarItem.selectedImage =  #imageLiteral(resourceName: "icNewsFeedPressed").withRenderingMode(.alwaysOriginal)
        
        let searchVC = searchVC
//        let viewSearch = searchVC.view
        searchVC.tabBarItem = UITabBarItem(title: "Tìm kiếm", image: #imageLiteral(resourceName: "icSearchNormal"), tag: 1)
        searchVC.tabBarItem.selectedImage =  #imageLiteral(resourceName: "icSearchPressed").withRenderingMode(.alwaysOriginal)
        
        let myRoomVC = myRoomVC
//        let viewMyRoom = myRoomVC.view
        myRoomVC.tabBarItem = UITabBarItem(title: "Quản lý", image: #imageLiteral(resourceName: "icRoomNormal"), tag: 2)
        myRoomVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "icRoomPressed").withRenderingMode(.alwaysOriginal)
        
        let myAccountVC = myAccountVC
//        let viewMyAccount = myAccountVC.view
        myAccountVC.tabBarItem = UITabBarItem(title: "Tài khoản", image: #imageLiteral(resourceName: "icUserNormal"), tag: 3)
        myAccountVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "icUserPressed").withRenderingMode(.alwaysOriginal)
        
        let settingVC = settingVC
//        let viewSetting = settingVC.view
        settingVC.tabBarItem = UITabBarItem(title: "Khác", image: #imageLiteral(resourceName: "icMenuBlack"), tag: 4)
        settingVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "icMenuBlue").withRenderingMode(.alwaysOriginal)
        
        listViewController.append(homeScreenVC)
        listViewController.append(searchVC)
        listViewController.append(myRoomVC)
        listViewController.append(myAccountVC)
        listViewController.append(settingVC)
  
//        let textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.54)
        
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: textColor], for: .normal)
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: textColor], for: .selected)
        
        tabbarController.setViewControllers(listViewController, animated: true)
        tabbarController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tabbarController.view.frame = vContent.bounds
        tabbarController.tabBar.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        
        vContent.autoresizesSubviews = true
        vContent.addSubview(tabbarController.view)
        self.addChildViewController(tabbarController)
    }
    
    
    func setupTabbar(homeScreenVC: UIViewController, searchVC: UIViewController, myRoomVC: UIViewController, settingVC: UIViewController) {
        
        listViewController.removeAll()
        
        self.tabbarController.delegate = self
        
        let homeScreenVC = homeScreenVC
        //        let viewHomeScreen = homeScreenVC.view
        homeScreenVC.tabBarItem = UITabBarItem(title: "Bảng tin", image: #imageLiteral(resourceName: "icNewsFeedNormal"), tag: 0)
        homeScreenVC.tabBarItem.selectedImage =  #imageLiteral(resourceName: "icNewsFeedPressed").withRenderingMode(.alwaysOriginal)
        
        let searchVC = searchVC
        //        let viewSearch = searchVC.view
        searchVC.tabBarItem = UITabBarItem(title: "Tìm kiếm", image: #imageLiteral(resourceName: "icSearchNormal"), tag: 1)
        searchVC.tabBarItem.selectedImage =  #imageLiteral(resourceName: "icSearchPressed").withRenderingMode(.alwaysOriginal)
        
        let myRoomVC = myRoomVC
        //        let viewMyRoom = myRoomVC.view
        myRoomVC.tabBarItem = UITabBarItem(title: "Đang thuê", image: #imageLiteral(resourceName: "icRoomNormal"), tag: 2)
        myRoomVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "icRoomPressed").withRenderingMode(.alwaysOriginal)
        
        let settingVC = settingVC
        //        let viewSetting = settingVC.view
        settingVC.tabBarItem = UITabBarItem(title: "Khác", image: #imageLiteral(resourceName: "icMenuBlack"), tag: 4)
        settingVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "icMenuBlue").withRenderingMode(.alwaysOriginal)
        
        listViewController.append(homeScreenVC)
        listViewController.append(searchVC)
        listViewController.append(myRoomVC)
        listViewController.append(settingVC)
        
        //        let textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.54)
        
        //        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: textColor], for: .normal)
        //        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: textColor], for: .selected)
        
        tabbarController.setViewControllers(listViewController, animated: true)
        tabbarController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tabbarController.view.frame = vContent.bounds
        tabbarController.tabBar.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        
        vContent.autoresizesSubviews = true
        vContent.addSubview(tabbarController.view)
        self.addChildViewController(tabbarController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentUser = Auth.auth().currentUser
        let uid = currentUser?.uid
        let ref = Database.database().reference().child("Users").child(uid!)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let userType = (dictionary["UserType"] as? Int)!
                
                if userType == 0 {
                    // Set up tabbar for owner
                    self.setupTabbar(homeScreenVC: self.vcHomeScreen, searchVC: self.vcSearch, myRoomVC: self.vcRoomManager, myAccountVC: self.vcAccount, settingVC: self.vcSetting)
                    self.tabbarController.tabBar.reloadInputViews()
                    
                }
                else if userType == 1 {
                    // Set up tabbar for renter
                    self.setupTabbar(homeScreenVC: self.vcHomeScreen, searchVC: self.vcSearch, myRoomVC: self.vcMyRooms, settingVC: self.vcSetting)
                    //tabbarController.selectedIndex = 3'
                }
            }
        }, withCancel: nil)
        
        self.navigationController?.swipeBackEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.swipeBackEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setViewController(selectedIndex: Int) {
        self.tabbarController.selectedIndex = selectedIndex
    }
    
    func hideTabBar(_ tabbarcontroller: UITabBarController) {
        let screenRect: CGRect = UIScreen.main.bounds
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        tabbarcontroller.view.frame = CGRect(x: tabbarcontroller.view.frame.origin.x, y: tabbarcontroller.view.frame.origin.y, width: tabbarcontroller.view.frame.width, height: screenRect.height + tabbarcontroller.tabBar.frame.height)
        UIView.commitAnimations()
    }
    
    func showTabBar(_ tabbarcontroller: UITabBarController) {
        let screenRect: CGRect = UIScreen.main.bounds
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        tabbarcontroller.view.frame = screenRect
        UIView.commitAnimations()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UITabBarController {
    
    func hideTabBar() {
        let screenRect: CGRect = UIScreen.main.bounds
        
        self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: screenRect.height + self.tabBar.frame.height)
    }
    
    func showTabBar() {
        let screenRect: CGRect = UIScreen.main.bounds
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        self.view.frame = screenRect
        UIView.commitAnimations()
    }
}

