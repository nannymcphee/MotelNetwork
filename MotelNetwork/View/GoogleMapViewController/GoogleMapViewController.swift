//
//  GoogleMapViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/27/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

//struct NewsLocation {
//    let title: String
//    let lat: CLLocationDegrees
//    let long: CLLocationDegrees
//}


import UIKit
import GoogleMaps
import FirebaseDatabase

class GoogleMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    var listNews = [News]()
    var listCoordinate = [CLLocationCoordinate2D]()
    var locationManager = CLLocationManager()
    var listNewsLocation = [NewsLocation]()
    var markers = [GMSMarker]()
    var currentLocation: CLLocation?
    var zoomLevel: Float = 15
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
//        showLoading()
        loadData()
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
                let location = NewsLocation(dictionary: dictionary)
                news.id = snapshot.key
                
                DispatchQueue.main.async {
                    self.reloadInputViews()
                }
                
                let priceStr = dictionary["price"] as? String
                let waterPriceStr = dictionary["waterPrice"] as? String
                let electricPriceStr = dictionary["electricPrice"] as? String
                let internetPriceStr = dictionary["internetPrice"] as? String
                
                news.price = Double(priceStr ?? "0.0")
                news.waterPrice = Double(waterPriceStr ?? "0.0")
                news.electricPrice = Double(electricPriceStr ?? "0.0")
                news.internetPrice = Double(internetPriceStr ?? "0.0")
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
                news.postDate = dictionary["postDate"] as? String
                
                location.address = dictionary["address"] as? String
                location.title = dictionary["title"] as? String
                
                self.listNews.append(news)
                self.listNewsLocation.append(location)

//                self.stopLoading()
            }
            self.convertAddressToCoordinate()

        }, withCancel: nil)
        
    }

    //MARK: Convert address to coordinate
    
    func convertAddressToCoordinate() {
        
        let geoCoder = CLGeocoder()
        
        for i in 0..<listNewsLocation.count {
            geoCoder.geocodeAddressString(listNewsLocation[i].address!) { (placemark, error) in
                guard
                    let placemark = placemark, let location = placemark.first?.location else {
                        // Handle no location found
                        print(error?.localizedDescription ?? "No error found.")
                        return
                }
                
                self.listCoordinate.append(location.coordinate)
                
                for i in 0..<self.listCoordinate.count {
                    let marker = GMSMarker(position: self.listCoordinate[i])
//                    marker.title = "Bài đăng \(i)"
                    marker.map = self.mapView
                    self.markers.append(marker)
                }
            }
        }
    }

//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//        for i in 0..<self.locationsArray.count {
//            let marker = GMSMarker(position: self.locationsArray[i])
//            if marker == marker {
//                let vc = DetailNewsViewController()
//                let news = listNews[i]
//                vc.currentNews = news
//                (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
//            }
//        }
//        return true
//    }
    
    
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
            
            let locationValue: CLLocationCoordinate2D = manager.location!.coordinate
            
            let camera = GMSCameraPosition.camera(withTarget: locationValue, zoom: zoomLevel)
            
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            }
            else {
                mapView.animate(to: camera)
                
                let currentLocationMarker = GMSMarker(position: locationValue)
                
                currentLocationMarker.title = "Vị trí hiện tại"
                currentLocationMarker.map = mapView
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
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print(error.localizedDescription)
    }
}
