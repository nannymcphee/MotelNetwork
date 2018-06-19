//
//  TestLoginViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 6/14/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import ILLoginKit

class TestLoginViewController: UIViewController {
    
    var hasShownLogin = false
    
    lazy var loginCoordinator: LoginCoordinator = {
        return LoginCoordinator(rootViewController: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard !hasShownLogin else {
            return
        }
        
        hasShownLogin = true
        loginCoordinator.start()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: - LoginViewController Delegate

extension TestLoginViewController: LoginViewControllerDelegate {
    
    func didSelectLogin(_ viewController: UIViewController, email: String, password: String) {
        print("DID SELECT LOGIN; EMAIL = \(email); PASSWORD = \(password)")
        doLogin(email: email, pass: password)
    }
    
    func didSelectForgotPassword(_ viewController: UIViewController) {
        print("LOGIN DID SELECT FORGOT PASSWORD")
    }
    
    func loginDidSelectBack(_ viewController: UIViewController) {
        print("LOGIN DID SELECT BACK")
    }
    
}
