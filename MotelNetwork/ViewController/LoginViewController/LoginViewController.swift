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
    
    @IBAction func btnLoginPressed(_: UIButton) {
        
        if let email = tfEmail.text, let pass = tfPassword.text {
            
            Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
                
                // Check if user is nil
                if let u = user {
                    // User found, go to HomeViewController
                    let vc = BeforeSignHomeViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    if let firebaseError = error {
                        print(firebaseError.localizedDescription)
                        return
                }
            }
        }
    }
}
    
    @IBAction func btnRegisterNavigationPressed(_ sender: Any) {
        //self.show(SignUpViewController(), sender: nil)
        let vc = SignUpViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

    
    @IBAction func btnForgotPasswordPressed(_ sender: UIButton) {
        //self.show(SignUpViewController(), sender: nil)
        let vc = ForgotPasswordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
