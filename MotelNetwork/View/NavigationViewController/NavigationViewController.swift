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
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnGo: UIButton!
    @IBOutlet weak var tfOrigin: UITextField!
    @IBOutlet weak var tfDestination: UITextField!
    
    var currentNews = News()
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var currentLocationCoordinate: CLLocationCoordinate2D?
    var currentNewsCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocationManager()
        setUpView()        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set up view
    
    func setUpView() {
        
        let lat = currentNews.lat?.toDouble
        let long = currentNews.long?.toDouble
        
        self.currentNewsCoordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        tfDestination.text = currentNews.address!
        makeButtonRounded(button: btnGo)
    }
    
    //MARK: Logic for locationManager
    
    func setUpLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        self.locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if currentLocation == nil {
            currentLocation = locations.last
            locationManager?.stopMonitoringSignificantLocationChanges()
            
            let locationValue: CLLocationCoordinate2D = manager.location!.coordinate
            
            currentLocationCoordinate = locationValue
            
            locationManager?.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnGoPressed(_ sender: Any) {
        
        if (tfOrigin.text?.isEmpty)! || (tfDestination.text?.isEmpty)! {
            showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
        }
        else if tfOrigin.text == "Vị trí của bạn" {
            if self.currentLocation != nil {
                navigateFromCoordinateToCoordinate()
            }
            else {
                showAlert(title: "Thông báo", alertMessage: messageGPSAccessDenied)
            }
        }
        else if tfOrigin.text != "Vị trí của bạn" {
            navigateFromPlaceToCoordinate()
        }
        
    }

}

extension NavigationViewController: PXGoogleDirectionsDelegate {
    
    //MARK: PXLocation
    
    func navigateFromCoordinateToCoordinate() {
        directionsAPI.delegate = self
        directionsAPI.from = PXLocation.coordinateLocation(currentLocationCoordinate!)
        directionsAPI.to = PXLocation.coordinateLocation(currentNewsCoordinate!)
        directionsAPI.region = "vi-vn"
        
        directionsAPI.calculateDirections { (response) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                switch response {
                case let .error(_, error):
                    self.showAlert(title: "Lỗi", alertMessage: "Error: \(error.localizedDescription)")
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
    
    func navigateFromPlaceToCoordinate() {
        directionsAPI.delegate = self
        directionsAPI.from = PXLocation.namedLocation(tfOrigin.text!)
        directionsAPI.to = PXLocation.coordinateLocation(currentNewsCoordinate!)
        directionsAPI.region = "vi-vn"
        
        directionsAPI.calculateDirections { (response) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                switch response {
                case let .error(_, error):
                    self.showAlert(title: "Lỗi", alertMessage: "Error: \(error.localizedDescription)")
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
    
    fileprivate var directionsAPI: PXGoogleDirections {
        return (UIApplication.shared.delegate as! AppDelegate).directionsAPI
    }
    
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





