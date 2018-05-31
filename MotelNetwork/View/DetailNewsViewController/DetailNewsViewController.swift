//
//  SignedInDetailNewsViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/4/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Kingfisher
import Floaty
import ImageSlideshow
import MXParallaxHeader

class DetailNewsViewController: UIViewController {
    
    @IBOutlet weak var svContent: UIScrollView!
    @IBOutlet weak var vHeader: UIView!
    @IBOutlet weak var lblTimeAgo: UILabel!
    @IBOutlet weak var vSlideShow: ImageSlideshow!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tvPhoneNumber: UITextView!
    @IBOutlet weak var btnBack2: UIButton!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblDistrict: UILabel!
    @IBOutlet weak var lblWaterPrice: UILabel!
    @IBOutlet weak var lblElectricPrice: UILabel!
    @IBOutlet weak var lblPostDate: UILabel!
    @IBOutlet weak var lblInternetPrice: UILabel!
    @IBOutlet weak var tvAddress: UITextView!
    @IBOutlet weak var tvDescription: UITextView!
    
    var currentNews = News()
    var floaty = Floaty()
    var userType: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Set up view
    
    func setUpView() {
        
        layoutFAB()
        setUpSlideShow()
        
        numberFormatter.numberStyle = .decimal
        var dateStr: String = ""
        let formattedPrice = numberFormatter.string(from: currentNews.price! as NSNumber)
        let formattedElectricPrice = numberFormatter.string(from: currentNews.electricPrice! as NSNumber)
        let formattedWaterPrice = numberFormatter.string(from: currentNews.waterPrice! as NSNumber)
        let formattedInternetPrice = numberFormatter.string(from: currentNews.internetPrice! as NSNumber)
        let timestampDouble = Double(currentNews.timestamp!)
        let timestampDate = NSDate(timeIntervalSince1970: timestampDouble)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateStr = dateFormatter.string(from: timestampDate as Date)
        
        if let ownerID = currentNews.ownerID {
            
            let ref = Database.database().reference().child("Users").child(ownerID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    if let userProfileImageUrl = dictionary["ProfileImageUrl"] as? String {
                        
                        self.loadImageToImageView(imageUrl: userProfileImageUrl, imageView: self.ivAvatar)
                    }
                    
                    if let userName = dictionary["FullName"] as? String {
                        self.lblUserName.text = userName
                    }
                }
            }, withCancel: nil)
        }

//        lblTimeAgo.text = Date.timeAgoDisplay(timestampDate as Date)()
        lblTimeAgo.text = timeAgoSince(timestampDate as Date)
        lblPrice.text = "\(formattedPrice ?? "")đ"
        lblElectricPrice.text = "\(formattedElectricPrice ?? "")đ"
        lblWaterPrice.text = "\(formattedWaterPrice ?? "")đ"
        lblInternetPrice.text = "\(formattedInternetPrice ?? "")đ"
        lblArea.text = String("\(currentNews.area ?? "")m2")
        lblDistrict.text = currentNews.district
        tvDescription.text = currentNews.description
        tvPhoneNumber.text = currentNews.phoneNumber
        lblPostDate.text = dateStr
        tvAddress.text = currentNews.address
        lblTitle.text = currentNews.title
        
        makeImageViewRounded(imageView: ivAvatar)
        svContent.parallaxHeader.view = vHeader
        svContent.parallaxHeader.height = 64
        svContent.parallaxHeader.minimumHeight = 0
        svContent.parallaxHeader.mode = .fill
    }
    
    func setUpSlideShow() {
        let postImageUrl0 = currentNews.postImageUrl0
        let postImageUrl1 = currentNews.postImageUrl1
        let postImageUrl2 = currentNews.postImageUrl2
        let placeholderImage = UIImage(named: "defaultImage")
        let placeholderSource = [ImageSource(image: placeholderImage!), ImageSource(image: placeholderImage!), ImageSource(image: placeholderImage!)]
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImage))

        if postImageUrl1 == nil || postImageUrl2 == nil {
            
            let source = [KingfisherSource(urlString: postImageUrl0!),
                          ImageSource(image: placeholderImage!),
                          ImageSource(image: placeholderImage!)]
            
            vSlideShow.setImageInputs(source as! [InputSource])
        }
        else if postImageUrl0 == nil && postImageUrl1 == nil && postImageUrl2 == nil {
            vSlideShow.setImageInputs(placeholderSource)
        }
        else {
            
            let kingfisherSource = [KingfisherSource(urlString: postImageUrl0!),
                                    KingfisherSource(urlString: postImageUrl1!),
                                    KingfisherSource(urlString: postImageUrl2!)]
            
            vSlideShow.setImageInputs(kingfisherSource as! [InputSource])
        }
        
        vSlideShow.backgroundColor = UIColor.white
        vSlideShow.slideshowInterval = 0
        vSlideShow.pageControlPosition = PageControlPosition.insideScrollView
        vSlideShow.pageControl.currentPageIndicatorTintColor = myBlue
        vSlideShow.pageControl.pageIndicatorTintColor = UIColor.white
        vSlideShow.circular = false
        vSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        vSlideShow.activityIndicator = DefaultActivityIndicator()
        vSlideShow.addGestureRecognizer(recognizer)
    }
    
    @objc func didTapImage() {
        let fullScreenController = vSlideShow.presentFullScreenController(from: self)
        
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
        fullScreenController.slideshow.circular = false
    }
    

    //MARK: Handling button pressed
    
    @IBAction func btnBack2Pressed(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
}

extension DetailNewsViewController: FloatyDelegate {
    func layoutFAB() {
       
        floaty.paddingX = self.view.frame.width / 2 - floaty.frame.width * 3
        floaty.fabDelegate = self
        floaty.buttonImage = #imageLiteral(resourceName: "icDirection-1")
        floaty.buttonColor = UIColor.white
//        floaty.buttonColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        self.view.addSubview(floaty)
    }
    
    // MARK: - Floaty Delegate Methods
    func emptyFloatySelected(_ floaty: Floaty) {
        let vc = ResultViewController()
        let news = currentNews
        
        vc.currentNews = news
//        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true)
    }
}




