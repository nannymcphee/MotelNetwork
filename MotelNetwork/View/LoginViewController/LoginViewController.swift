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
    
    var verificationTimer : Timer = Timer()    // Timer's  Global declaration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapToDismissKeyboard()
        btnLogin.layer.cornerRadius = 5
//        self.verificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(LoginViewController.checkIsEmailVerified) , userInfo: nil, repeats: true)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
       self.navigationController?.swipeBackEnabled = false
    }
    
//    @objc func checkIsEmailVerified() {
//
//        let email = self.tfEmail.text!
//        let pass = self.tfPassword.text!
//
//        Auth.auth().currentUser?.reload(completion: { (error) in
//            if error == nil {
//
//                if (Auth.auth().currentUser?.isEmailVerified)! {
//
//                    self.verificationTimer.invalidate()
//                    self.doLogin(email: email, pass: pass)
//                }
//                else {
//                    self.showAlert(alertMessage: "Email chưa được kích hoạt.")
//                }
//            }
//            else {
//                print(error?.localizedDescription ?? "")
//            }
//        })
//    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnLoginPressed(_: UIButton) {
        
        let email = tfEmail.text!
        let pass = tfPassword.text!

        if email.isEmpty || pass.isEmpty {

            showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
        }
        else if !isValidEmail(email: email) {

            showAlert(title: "Thông báo", alertMessage: messageInvalidEmail)
        }
        else {

            doLogin(email: email, pass: pass)
//            checkIsEmailVerified()
            return
        }
        
    }
    
    @IBAction func btnRegisterNavigationPressed(_ sender: Any) {
        
        let vc = SignUpViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true)
    }

    
    @IBAction func btnForgotPasswordPressed(_ sender: UIButton) {
        
        let vc = ForgotPasswordViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true)
    }
    
    
    
    

}
