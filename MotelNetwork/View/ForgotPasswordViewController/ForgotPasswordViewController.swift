//
//  ForgotPasswordViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 3/25/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var tfRecoveryEmail: UITextField!
    @IBOutlet weak var btnRecoverPassword: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapToDismissKeyboard()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func btnExitPressed(_ sender: Any) {
//        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnRecoverPasswordPressed(_ sender: Any) {
        
        if (tfRecoveryEmail.text?.isEmpty)! {
            
            self.showAlert(title: "Thông báo", alertMessage: "Vui lòng nhập email.")
        }
        else {
            
            let email = tfRecoveryEmail.text
            
            Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
                if error != nil {
                    
                    self.showAlert(title: "Thông báo", alertMessage: "\(error ?? "" as! Error)")
                }
                else {
                    
                    self.showAlert(title: "Thông báo", alertMessage: "Vui lòng kiểm tra email của bạn.")
                }
            }
        }
    }
    


}
