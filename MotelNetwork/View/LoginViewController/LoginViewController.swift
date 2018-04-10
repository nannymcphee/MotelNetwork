//
//  LoginViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 3/25/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegisterNavigation: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnLoginPressed(_: UIButton) {
        
        let email = tfEmail.text
        let pass = tfPassword.text
        
        if tfEmail.text == "" || tfPassword.text == "" {
            
            showAlert(alertMessage: messageNilTextFields)
        }
        else if !isValidEmail(email: email!) {
            
            showAlert(alertMessage: messageInvalidEmail)
        }
        else {
            doLogin(email: email!, pass: pass!)
        }
    }
    
    @IBAction func btnRegisterNavigationPressed(_ sender: Any) {
        
        let vc = SignUpViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    @IBAction func btnForgotPasswordPressed(_ sender: UIButton) {
        
        let vc = ForgotPasswordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    

}
