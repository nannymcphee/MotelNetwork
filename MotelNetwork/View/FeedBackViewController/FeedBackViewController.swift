//
//  FeedBackViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 6/3/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class FeedBackViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var tvFeedBack: UITextView!
    @IBOutlet weak var btnClear: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tvFeedBack.layer.cornerRadius = 5
        makeButtonRounded(button: btnSubmit)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnClearPressed(_ sender: Any) {
        
        self.tvFeedBack.text = ""
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmitPressed(_ sender: Any) {
        
        if self.tvFeedBack.text == "" {
            
            self.showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
        }
        else {
            
            let uid = Auth.auth().currentUser?.uid
            let ref = Database.database().reference().child("Feedbacks").childByAutoId()
            let feedback = self.tvFeedBack.text!
            let timestamp = Int(NSDate().timeIntervalSince1970)
            let values = ["from": uid!, "feedback": feedback, "timestamp": timestamp] as [String: AnyObject]
            
            self.storeInformationToDatabase(reference: ref, values: values)
            NativePopup.show(image: Preset.Feedback.done, title: messageSendFeedbackSuccess, message: nil, duration: 1.5, initialEffectType: .fadeIn)
            DispatchQueue.main.async {
                
                self.tvFeedBack.text = ""
                self.view.endEditing(true)
            }
        }
    }
    
}
