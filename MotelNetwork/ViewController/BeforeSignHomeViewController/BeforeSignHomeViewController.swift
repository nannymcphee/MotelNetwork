//
//  BeforeSignHomeViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/2/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class BeforeSignHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var tbListNews: UITableView!
    @IBOutlet weak var sbSearch: UITextField!
    @IBOutlet weak var btnNavigateLogin: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbListNews.delegate = self
        tbListNews.dataSource = self
        tbListNews.register(UINib(nibName: "ListNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListNewsTableViewCell")
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbListNews.dequeueReusableCell(withIdentifier: "ListNewsTableViewCell") as! ListNewsTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.lblTitle.text = "Cho thuê phòng trọ tại Thích Quảng Đức"
            cell.lblArea.text = "30m2"
            cell.lblPrice.text = "4.000.000đ"
            cell.lblLocation.text = "Phú Nhuận"
        case 1:
            cell.lblTitle.text = "Phòng trọ cao cấp tại D2"
            cell.lblArea.text = "40m2"
            cell.lblPrice.text = "6.000.000đ"
            cell.lblLocation.text = "Bình Thạnh"
        case 2:
            cell.lblTitle.text = "Phòng trọ mới xây quận Tân Phú"
            cell.lblArea.text = "25m2"
            cell.lblPrice.text = "2.500.000đ"
            cell.lblLocation.text = "Tân Phú"
        case 3:
            cell.lblTitle.text = "Phòng trọ cao cấp gần chợ Hoàng Hoa Thám"
            cell.lblArea.text = "35m2"
            cell.lblPrice.text = "5.000.000đ"
            cell.lblLocation.text = "Tân Bình"
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = BeforeSignDetailNewsViewController()
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnNavigateLoginPressed(_ sender: Any) {
        let vc = LoginViewController()
       (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
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
