//
//  GoogleMapViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/27/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase
import ObjectMapper

class GoogleMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    var listNews = [News]()
    var locationManager = CLLocationManager()
    var markers = [GMSMarker]()
    var currentLocation: CLLocation?
    var zoomLevel: Float = 15
    var customMapStyle: GMSMapStyle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        customMapStyle = try! GMSMapStyle.init(contentsOfFileURL: Bundle.main.url(forResource: "mapStyle", withExtension: "json")!)
        mapView.mapStyle = customMapStyle
        
        loadData2()
        setUpLocationManager()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Database interaction
    
    func loadData() {
        let ref = Database.database().reference().child("Posts")
        
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let news = News(dictionary: dictionary)
                news.id = snapshot.key
                
                DispatchQueue.main.async {
                    self.reloadInputViews()
                }
                
                let priceStr = dictionary["price"] as? String
                let waterPriceStr = dictionary["waterPrice"] as? String
                let electricPriceStr = dictionary["electricPrice"] as? String
                let internetPriceStr = dictionary["internetPrice"] as? String
                
//                news.price = Double(priceStr ?? "0.0")
//                news.waterPrice = Double(waterPriceStr ?? "0.0")
//                news.electricPrice = Double(electricPriceStr ?? "0.0")
//                news.internetPrice = Double(internetPriceStr ?? "0.0")
                news.price = priceStr
                news.waterPrice = waterPriceStr
                news.electricPrice = electricPriceStr
                news.internetPrice = internetPriceStr
                news.area = dictionary["area"] as? String
                news.district = dictionary["district"] as? String
                news.title = dictionary["title"] as? String
                news.address = dictionary["address"] as? String
                news.description = dictionary["description"] as? String
                news.phoneNumber = dictionary["phoneNumber"] as? String
                news.ownerID = dictionary["ownerID"] as? String
                news.postImageUrl0 = dictionary["postImageUrl0"] as? String
                news.postImageUrl1 = dictionary["postImageUrl1"] as? String
                news.postImageUrl2 = dictionary["postImageUrl2"] as? String
                news.timestamp = dictionary["timestamp"] as? Int
                news.lat = dictionary["lat"] as? String
                news.long = dictionary["long"] as? String
                news.views = dictionary["views"] as? Int
                
                self.listNews.append(news)
            }

        }, withCancel: nil)
    }
    
    func loadData2() {
        let ref = Database.database().reference().child("Posts")
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let json = snapshot.value as? [String: AnyObject] {
                var news = News()
                
                news = Mapper<News>().map(JSON: json) ?? News()
                
                self.listNews.append(news)
            }
        }, withCancel: nil)
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let marker = marker
        
        if let index = markers.index(of: marker) {
            let news = listNews[index]
            let infoView = MarkerInfoView.instanceFromNib() as? MarkerInfoView

            numberFormatter.numberStyle = .decimal
            let priceStr = numberFormatter.string(from: Double(news.price!)! as NSNumber)
            infoView?.lblTitle.text = news.title
            infoView?.lblArea.text = "\(news.area!)m2"
            infoView?.lblPrice.text = "\(priceStr!)đ"
            infoView?.lblAddress.text = news.address
            infoView?.layer.cornerRadius = 5

            return infoView
        }
        else {
            return nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        if let index = markers.index(of: marker) {
            
            let vc = DetailNewsViewController()
            let news = listNews[index]
            let postID = news.id
            let ref = Database.database().reference().child("Posts").child(postID!).child("views")

            increaseViewForPost(reference: ref)
            vc.currentNews = news
            (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
}

extension GoogleMapViewController {
    
    func setUpLocationManager() {
        
        locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 50
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if currentLocation == nil {
            currentLocation = locations.last
            locationManager.stopMonitoringSignificantLocationChanges()
            
            let locationValue: CLLocationCoordinate2D = locationManager.location!.coordinate
            
            let camera = GMSCameraPosition.camera(withTarget: locationValue, zoom: zoomLevel)
            
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            }
            else {
                
                mapView.animate(to: camera)
                
                for news in listNews {
                    
                    let lat = news.lat?.toDouble
                    let long = news.long?.toDouble
                    let location = CLLocationCoordinate2D(latitude: lat!, longitude: long!)                   
                    let marker = GMSMarker(position: location)
                    
//                    marker.title = news.title
//                    marker.snippet = news.address
//                    marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.25)
                    marker.icon = scaleImage(image: UIImage(named: "icMarker")!, scaledToSize: CGSize(width: 32.0, height: 32.0))
                    
                    markers.append(marker)
                    marker.map = mapView
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
            self.showAlert(title: "Thông báo", alertMessage: messageGPSAccessDenied)
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            fallthrough
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            print("Location status is OK.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print(error.localizedDescription)
    }
}
