//
//  MainViewController.swift
//  MotelNetwork
//
//  Created by Nguyen Seven on 4/5/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit


class MainViewController: UIViewController, UITabBarControllerDelegate {
    
    var listViewController = [UIViewController]()
    var tabbarController: UITabBarController = UITabBarController()
    
    var vcHomeScreen = BeforeSignHomeViewController()
    var vcPurchase = SignedInHomeViewController()
    
    var vcRoomanager = RoomManagementViewController()
   
    var vcAccountSetting = AccountViewController()
    
    var isAppearWhenFirstCreateMerchant = false
    
    @IBOutlet weak var vContent: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
    }
    
    func setupTabbar(homeScreenVC: UIViewController, newListingVC: UIViewController, myListingVC: UIViewController) {
       
        listViewController.removeAll()
        
        self.tabbarController.delegate = self
        
        let homeScreenVC = homeScreenVC
        let viewHomeScreen = homeScreenVC.view
        homeScreenVC.tabBarItem = UITabBarItem(title: "Tin tức", image: #imageLiteral(resourceName: "icNewsFeedNormal"), tag: 0)
        homeScreenVC.tabBarItem.selectedImage =  #imageLiteral(resourceName: "icNewsFeedPressed").withRenderingMode(.alwaysOriginal)
        
        let newListingVC = newListingVC
        let viewNewListing = newListingVC.view
        newListingVC.tabBarItem = UITabBarItem(title: "Phòng trọ của tôi", image: #imageLiteral(resourceName: "icRoomNormal"), tag: 1)
        newListingVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "icRoomPressed").withRenderingMode(.alwaysOriginal)
        
        let myListingVC = myListingVC
        let viewMyListing = myListingVC.view
        myListingVC.tabBarItem = UITabBarItem(title: "Tài khoản", image: #imageLiteral(resourceName: "icUserNormal"), tag: 2)
        myListingVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "icUserPressed").withRenderingMode(.alwaysOriginal)
        //myListingVC.tabBarItem.selectedImage?.renderingMode = .alwaysOriginal
        
       
        
        
        // newListingVC.tabBarItem.selectedImage?.renderingMode = .alwaysOriginal
        
        
        listViewController.append(homeScreenVC)
        listViewController.append(newListingVC)
        listViewController.append(myListingVC)
  
        
        
        let textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.54)
        
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
//        let currentUser = ApplicationAssembler.sharedInstance.resolver.resolve(PAuthenticationService.self)?.getCurrentUser()
        //let merchant = ApplicationAssembler.sharedInstance.resolver.resolve(PMerchantService.self)?.getCurrentMerchant()
//        if currentUser != nil {
//            if currentUser?.isMerchant == 1 || currentUser?.isMerchant == 2 {
//                setupTabbar(homeScreenVC: vcHomeScreen, newListingVC: vcPurchase, myListingVC: vcMainListing, moreSettingVC: vcMoreSetting)
//            } else {
//                setupTabbar(homeScreenVC: vcHomeScreen, newListingVC: vcPurchase, myListingVC: vcNewListing, moreSettingVC: vcMoreSetting)
//            }
//        } else {
//            setupTabbar(homeScreenVC: vcHomeScreen, newListingVC: vcTest, myListingVC: vcNewListing, moreSettingVC: vcMoreSetting)
//        }
//
//
//        if currentUser == nil {
//            DispatchQueue.main.async {
//                self.hideTabBar(self.tabbarController)
//            }
//
//        } else {
//            DispatchQueue.main.async {
//                self.showTabBar(self.tabbarController)
//            }
//
//        }
//
//        if isAppearWhenFirstCreateMerchant {
//            tabbarController.selectedIndex = 2
//            isAppearWhenFirstCreateMerchant = false
//        }
        
        setupTabbar(homeScreenVC: vcHomeScreen, newListingVC: vcRoomanager, myListingVC: vcAccountSetting)
        
        tabbarController.tabBar.reloadInputViews()
        //tabbarController.selectedIndex = 3
        
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

