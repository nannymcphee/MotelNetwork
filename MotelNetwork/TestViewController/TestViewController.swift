//
//  TestViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/1/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var sclContent: UIScrollView!
    @IBOutlet weak var pcTutorial: UIPageControl!
    
    var screenWidth = UIScreen.main.bounds.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sclContent.delegate = self

        // Do any additional setup after loading the view.
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        let currentPage = contentOffsetX / screenWidth
        pcTutorial.currentPage = Int(currentPage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
