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

class ResultViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    var currentNews = News()
    var request: PXGoogleDirections!
    var results: [PXGoogleDirectionsRoute]!
    var routeIndex: Int = 0
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var currentLocationCoordinate: CLLocationCoordinate2D!
    var currentNewsCoordinate: CLLocationCoordinate2D!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lat = currentNews.lat?.toDouble
        let long = currentNews.long?.toDouble
        
        self.currentNewsCoordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateRoute()
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
        results[routeIndex].drawOriginMarkerOnMap(mapView, title: "Bắt đầu", color: UIColor.green, opacity: 1.0, flat: true)
        results[routeIndex].drawDestinationMarkerOnMap(mapView, title: self.currentNews.address!, color: UIColor.red, opacity: 1.0, flat: true)
    }
}
