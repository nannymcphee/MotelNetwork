//
//  ResultViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/23/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import PXGoogleDirections
import GoogleMaps

class ResultViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    var currentNews = News()
    var request: PXGoogleDirections!
    var results: [PXGoogleDirectionsRoute]!
    var routeIndex: Int = 0
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var currentLocationCoordinate: CLLocationCoordinate2D!
    var currentNewsCoordinate: CLLocationCoordinate2D!
    var customMapStyle: GMSMapStyle!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lat = currentNews.lat?.toDouble
        let long = currentNews.long?.toDouble
        
        self.currentNewsCoordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        
//        setUpLocationManager()
        setUpMapView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpLocationManager()
//        updateRoute()
    }
    
    func setUpMapView() {
        
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        customMapStyle = try! GMSMapStyle.init(contentsOfFileURL: Bundle.main.url(forResource: "mapStyle", withExtension: "json")!)
        mapView.mapStyle = customMapStyle
    }
    
    @IBAction func closeButtonTouched(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInGoogleMapsButtonTouched(_ sender: UIButton) {
//        if !request.openInGoogleMaps(center: nil, mapMode: .streetView, view: Set(arrayLiteral: PXGoogleMapsView.satellite, PXGoogleMapsView.traffic, PXGoogleMapsView.transit), zoom: 15, callbackURL: URL(string: "comexamplemotelnetwork"), callbackName: "MotelNetwork") {
//            self.showAlert(title: "Thông báo", alertMessage: "Không thể mở Bản đồ.")
//        }
        
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {

            let urlString = "http://maps.google.com/?saddr=&daddr=\(currentNewsCoordinate.latitude),\(currentNewsCoordinate.longitude)&directionsmode=driving"

            UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
        }
        else {

            let urlString = "http://maps.apple.com/maps?saddr=&daddr=\(currentNewsCoordinate.latitude),\(currentNewsCoordinate.longitude)&dirflg=d"

            UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
        }
    }
    
    func updateRoute() {

        for i in 0 ..< results.count {
            if i != routeIndex {
                results[i].drawOnMap(mapView, approximate: false, strokeColor: UIColor.lightGray, strokeWidth: 3.0)
            }
        }
        
        mapView.animate(with: GMSCameraUpdate.fit(results[routeIndex].bounds!, withPadding: 40.0))
        results[routeIndex].drawOnMap(mapView, approximate: false, strokeColor: myBlue, strokeWidth: 6.0)
        results[routeIndex].drawOriginMarkerOnMap(mapView, title: "Vị trí của bạn", color: UIColor.green, opacity: 1.0, flat: true)
        results[routeIndex].drawDestinationMarkerOnMap(mapView, title: self.currentNews.address!, color: UIColor.red, opacity: 1.0, flat: true)
    }
}

extension ResultViewController: CLLocationManagerDelegate {
    
    func setUpLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if currentLocation == nil {
            currentLocation = locations.last
            locationManager.stopMonitoringSignificantLocationChanges()
            
            let locationValue: CLLocationCoordinate2D = manager.location!.coordinate
            
            currentLocationCoordinate = locationValue
            navigateFromCoordinateToCoordinate()
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension ResultViewController: PXGoogleDirectionsDelegate {
    
    func navigateFromCoordinateToCoordinate() {
        directionsAPI.delegate = self
        directionsAPI.from = PXLocation.coordinateLocation(currentLocationCoordinate!)
        directionsAPI.to = PXLocation.coordinateLocation(currentNewsCoordinate!)
        directionsAPI.region = "vi-vn"
        
        directionsAPI.calculateDirections { (response) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                switch response {
                case let .error(_, error):
                    print(error.localizedDescription)
                    self.showAlert(title: "Lỗi", alertMessage: "Không thể tìm thấy chỉ đường (Sai địa chỉ).")
                case let .success(request, routes):
                    self.request = request
                    self.results = routes
                    self.updateRoute()
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
