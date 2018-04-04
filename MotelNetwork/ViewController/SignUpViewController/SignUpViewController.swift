//
//  SignUpViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 3/25/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class UserType {
    var userType: Int
    var userTypeName: String
    
    init(userType: Int, userTypeName: String) {
        self.userType = userType
        self.userTypeName = userTypeName
    }
}

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnExit: UIButton!
    @IBOutlet weak var pvUserType: UIPickerView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfCMND: UITextField!
    @IBOutlet weak var dpBirthday: UIDatePicker!
    
    var userType = [UserType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pvUserType.delegate = self
        pvUserType.dataSource = self
        
        userType.append(UserType(userType: 1, userTypeName: "Chủ nhà trọ"))
        userType.append(UserType(userType: 2, userTypeName: "Khách thuê trọ"))
        
        btnRegister.layer.cornerRadius = 15

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return userType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
        return userType[row].userTypeName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadComponent(0)
        
        let selectedUserType = pvUserType.selectedRow(inComponent: 0)
//        let userType2 = userType[selectedUserType].userType
    }
    
    @IBAction func btnExitPressed(_ sender: Any) {
        //self.navigationController?.pushViewController(LoginViewController(), animated: true)
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
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
