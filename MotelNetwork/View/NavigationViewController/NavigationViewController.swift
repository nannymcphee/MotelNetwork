//
//  GoogleMapViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/23/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import GoogleMaps
import PXGoogleDirections

class NavigationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var btnGetCurrentLocation: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnGo: UIButton!
    @IBOutlet weak var tfOrigin: UITextField!
    @IBOutlet weak var tfDestination: UITextField!
    
    var currentNews = News()
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var currentLocationCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocationManager()
        setUpView()        
    }
    
    func setUpView() {
        tfDestination.text = currentNews.address!
        makeButtonRounded(button: btnGo)
    }
    
    func setUpLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        self.locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if currentLocation == nil {
            currentLocation = locations.last
            locationManager?.stopMonitoringSignificantLocationChanges()
            
            let locationValue: CLLocationCoordinate2D = manager.location!.coordinate
            
            currentLocationCoordinate = locationValue
//            self.tfOrigin.text = "\(locationValue.latitude), \(locationValue.longitude)"
            
//            let geocoder = CLGeocoder()
//            geocoder.reverseGeocodeLocation(currentLocation!) { (placemark, error) in
//                if error != nil {
//                    print(error!)
//                }
//                else {
//                    self.tfOrigin.text = placemark![0].name
//                }
//            }
            
            locationManager?.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    fileprivate var directionsAPI: PXGoogleDirections {
        return (UIApplication.shared.delegate as! AppDelegate).directionsAPI
    }
    
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnGoPressed(_ sender: Any) {
        
        if (tfOrigin.text?.isEmpty)! || (tfDestination.text?.isEmpty)! {
            showAlert(alertMessage: messageNilTextFields)
        }
        else if tfOrigin.text == "Vị trí của bạn" || tfOrigin.text == "Vị trí của bạn (Mặc định)" {
            directionsAPI.delegate = self
            directionsAPI.from = PXLocation.coordinateLocation(currentLocationCoordinate!)
            directionsAPI.to = PXLocation.namedLocation(tfDestination.text!)
            directionsAPI.region = "vi-vn"
            
            directionsAPI.calculateDirections { (response) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    switch response {
                    case let .error(_, error):
                        self.showAlert(alertMessage: "Error: \(error.localizedDescription)")
                    case let .success(request, routes):
                        let rvc = ResultViewController()
                        rvc.request = request
                        rvc.results = routes
                        rvc.currentNews = self.currentNews
                        self.present(rvc, animated: true, completion: nil)
                    }
                })
            }
        }
        else if tfOrigin.text != "Vị trí của bạn" || tfOrigin.text == "Vị trí của bạn (Mặc định)" {
            directionsAPI.delegate = self
            directionsAPI.from = PXLocation.namedLocation(tfOrigin.text!)
            directionsAPI.to = PXLocation.namedLocation(tfDestination.text!)
            directionsAPI.region = "vi-vn"
            
            directionsAPI.calculateDirections { (response) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    switch response {
                    case let .error(_, error):
                        self.showAlert(alertMessage: "Error: \(error.localizedDescription)")
                    case let .success(request, routes):
                        let rvc = ResultViewController()
                        rvc.request = request
                        rvc.results = routes
                        rvc.currentNews = self.currentNews
                        self.present(rvc, animated: true, completion: nil)
                    }
                })
            }
        }
        else {
            directionsAPI.delegate = self
            directionsAPI.from = PXLocation.namedLocation(tfOrigin.text!)
            directionsAPI.to = PXLocation.namedLocation(tfDestination.text!)
            directionsAPI.region = "vi-vn"
            
            directionsAPI.calculateDirections { (response) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    switch response {
                    case let .error(_, error):
                        self.showAlert(alertMessage: "Error: \(error.localizedDescription)")
                    case let .success(request, routes):
                        let rvc = ResultViewController()
                        rvc.request = request
                        rvc.results = routes
                        rvc.currentNews = self.currentNews
                        self.present(rvc, animated: true, completion: nil)
                    }
                })
            }
        }
        
    }
    
    
    @IBAction func btnGetCurrentLocationPressed(_ sender: Any) {
        
        self.tfOrigin.text = "Vị trí của bạn"
    }
    
    
}

extension NavigationViewController: PXGoogleDirectionsDelegate {
    func googleDirectionsWillSendRequestToAPI(_ googleDirections: PXGoogleDirections, withURL requestURL: URL) -> Bool {
        NSLog("googleDirectionsWillSendRequestToAPI:withURL:")
        return true
    }
    
    func googleDirectionsDidSendRequestToAPI(_ googleDirections: PXGoogleDirections, withURL requestURL: URL) {
        NSLog("googleDirectionsDidSendRequestToAPI:withURL:")
        NSLog("\(requestURL.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)")
    }
    
    func googleDirections(_ googleDirections: PXGoogleDirections, didReceiveRawDataFromAPI data: Data) {
        NSLog("googleDirections:didReceiveRawDataFromAPI:")
        NSLog(String(data: data, encoding: .utf8)!)
    }
    
    func googleDirectionsRequestDidFail(_ googleDirections: PXGoogleDirections, withError error: NSError) {
        NSLog("googleDirectionsRequestDidFail:withError:")
        NSLog("\(error)")
    }
    
    func googleDirections(_ googleDirections: PXGoogleDirections, didReceiveResponseFromAPI apiResponse: [PXGoogleDirectionsRoute]) {
        NSLog("googleDirections:didReceiveResponseFromAPI:")
        NSLog("Got \(apiResponse.count) routes")
        for i in 0 ..< apiResponse.count {
            NSLog("Route \(i) has \(apiResponse[i].legs.count) legs")
        }
    }
}





