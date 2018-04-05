//
//  RoomManagementViewController.swift
//  MotelNetwork
//
//  Created by Phùng Trọng Huy on 4/4/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class RoomManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tbRoomManagement: UITableView!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblUserFullName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ivAvatar.layer.cornerRadius = self.ivAvatar.frame.size.width / 2
        ivAvatar.clipsToBounds = true
        
        tbRoomManagement.delegate = self
        tbRoomManagement.dataSource = self
       tbRoomManagement.register(UINib(nibName: "ListRoomsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListRoomsTableViewCell")
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
        let cell = tbRoomManagement.dequeueReusableCell(withIdentifier: "ListRoomsTableViewCell") as! ListRoomsTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.lblRoom.text = "Phòng 101"
            cell.lblRoomPrice.text = "4.000.000đ"
            cell.lblUserFullName.text = "Nguyễn Cao Cường"
        case 1:
            cell.lblRoom.text = "Phòng 102"
            cell.lblRoomPrice.text = "3.000.000đ"
            cell.lblUserFullName.text = "Nguyễn Lùn Cường"
        case 2:
            cell.lblRoom.text = "Phòng 103"
            cell.lblRoomPrice.text = "7.000.000đ"
            cell.lblUserFullName.text = "Nguyễn Thấp Cường"
        case 3:
            cell.lblRoom.text = "Phòng 104"
            cell.lblRoomPrice.text = "1.000.000đ"
            cell.lblUserFullName.text = "Nguyễn Siêu Cường"
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
