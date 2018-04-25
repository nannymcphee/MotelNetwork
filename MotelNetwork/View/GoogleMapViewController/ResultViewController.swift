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
    
    var request: PXGoogleDirections!
    var results: [PXGoogleDirectionsRoute]!
    var routeIndex: Int = 0
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
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
        if !request.openInGoogleMaps(center: nil, mapMode: .streetView, view: Set(arrayLiteral: PXGoogleMapsView.satellite, PXGoogleMapsView.traffic, PXGoogleMapsView.transit), zoom: 15, callbackURL: URL(string: "pxsample://"), callbackName: "PXSample") {
            self.showAlert(alertMessage: "Không thể mở Google Map.")
        }
    }
    
    func updateRoute() {

        for i in 0 ..< results.count {
            if i != routeIndex {
                results[i].drawOnMap(mapView, approximate: false, strokeColor: UIColor.lightGray, strokeWidth: 3.0)
            }
        }
        mapView.animate(with: GMSCameraUpdate.fit(results[routeIndex].bounds!, withPadding: 40.0))
        results[routeIndex].drawOnMap(mapView, approximate: false, strokeColor: UIColor.purple, strokeWidth: 4.0)
        results[routeIndex].drawOriginMarkerOnMap(mapView, title: "Xuất phát", color: UIColor.green, opacity: 1.0, flat: true)
        results[routeIndex].drawDestinationMarkerOnMap(mapView, title: "Đích đến", color: UIColor.red, opacity: 1.0, flat: true)
    }
}
