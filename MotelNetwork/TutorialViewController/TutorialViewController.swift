//
//  TutorialViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/1/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var btnGetStarted: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    var imageArr: [String] = ["Color Burst 1", "Color Burst 2", "Color Burst 3"]
    var frame = CGRect(x:0, y:0, width:0, height:0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.numberOfPages = imageArr.count
        for index in 0 ..< imageArr.count {
            frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            frame.size = scrollView.frame.size
            
            let imgView = UIImageView(frame: frame)
            imgView.image = UIImage(named: imageArr[index])
            self.scrollView.addSubview(imgView)
        }
        
        scrollView.contentSize = CGSize(width: (scrollView.frame.size.width * CGFloat(imageArr.count)), height: scrollView.frame.size.height)
        scrollView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
    }
    
    @IBAction func btnGetStartedClick(_ sender: Any) {
        let vc = LoginViewController()
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
