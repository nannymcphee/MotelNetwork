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
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnRecoverPasswordPressed(_ sender: Any) {
        if tfRecoveryEmail.text == "" {
            // Create UIAlertController
            let alert = UIAlertController(title: "Thông báo", message: "Email không được bỏ trống!", preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            })
            alert.addAction(actionOK)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let email = tfRecoveryEmail.text
            Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
                if error != nil {
                    let alert = UIAlertController(title: "Thông báo", message: "Error: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "Thông báo", message: "Vui lòng kiểm tra email của bạn", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
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
