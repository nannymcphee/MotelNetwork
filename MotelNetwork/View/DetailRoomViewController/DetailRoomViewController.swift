//
//  DetailRoomViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/10/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class DetailRoomViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var lblRoomName: UILabel!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var ivRoomImage: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var btnCalculate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnEditPressed(_ sender: Any) {
        
        let vc = EditRoomViewController()
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCalculatePressed(_ sender: Any) {
        
        let vc = CalculateRoomPriceViewController()
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
}
