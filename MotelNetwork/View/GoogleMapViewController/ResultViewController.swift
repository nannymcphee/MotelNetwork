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

//    @IBOutlet weak var prevButton: UIButton!
//    @IBOutlet weak var routesLabel: UILabel!
//    @IBOutlet weak var nextButton: UIButton!
//    @IBOutlet weak var directions: UITableView!

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
//
//    @IBAction func previousButtonTouched(_ sender: UIButton) {
//        routeIndex -= 1
//        updateRoute()
//    }
//
//    @IBAction func nextButtonTouched(_ sender: UIButton) {
//        routeIndex += 1
//        updateRoute()
//    }
    
    @IBAction func closeButtonTouched(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInGoogleMapsButtonTouched(_ sender: UIButton) {
        if !request.openInGoogleMaps(center: nil, mapMode: .streetView, view: Set(arrayLiteral: PXGoogleMapsView.satellite, PXGoogleMapsView.traffic, PXGoogleMapsView.transit), zoom: 15, callbackURL: URL(string: "pxsample://"), callbackName: "PXSample") {
            self.showAlert(alertMessage: "Không thể mở Google Map.")
        }
    }
    
    func updateRoute() {
//        prevButton.isEnabled = (routeIndex > 0)
//        nextButton.isEnabled = (routeIndex < (results).count - 1)
//        routesLabel.text = "\(routeIndex + 1) of \((results).count)"
//        mapView.clear()
        for i in 0 ..< results.count {
            if i != routeIndex {
                results[i].drawOnMap(mapView, approximate: false, strokeColor: UIColor.lightGray, strokeWidth: 3.0)
            }
        }
        mapView.animate(with: GMSCameraUpdate.fit(results[routeIndex].bounds!, withPadding: 40.0))
        results[routeIndex].drawOnMap(mapView, approximate: false, strokeColor: UIColor.purple, strokeWidth: 4.0)
        results[routeIndex].drawOriginMarkerOnMap(mapView, title: "Xuất phát", color: UIColor.green, opacity: 1.0, flat: true)
        results[routeIndex].drawDestinationMarkerOnMap(mapView, title: "Đích đến", color: UIColor.red, opacity: 1.0, flat: true)
//        directions.reloadData()
    }
}

//extension ResultViewController: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return (results[routeIndex].legs).count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return (results[routeIndex].legs[section].steps).count
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let leg = results[routeIndex].legs[section]
//        if let dist = leg.distance?.description, let dur = leg.duration?.description {
//            return "Step \(section + 1) (\(dist), \(dur))"
//        } else {
//            return "Step \(section + 1)"
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: "RouteStep")
//        if (cell == nil) {
//            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "RouteStep")
//        }
//        let step = results[routeIndex].legs[indexPath.section].steps[indexPath.row]
//        if let instr = step.rawInstructions {
//            cell!.textLabel!.text = instr
//        }
//        if let dist = step.distance?.description, let dur = step.duration?.description {
//            cell!.detailTextLabel?.text = "\(dist), \(dur)"
//        }
//        return cell!
//    }
//
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let step = results[routeIndex].legs[indexPath.section].steps[indexPath.row]
//        mapView.animate(with: GMSCameraUpdate.fit(step.bounds!, withPadding: 40.0))
//    }
//
//    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        let step = results[routeIndex].legs[indexPath.section].steps[indexPath.row]
//        var msg: String
//        if let m = step.maneuver {
//            msg = "\(step.rawInstructions!)\nGPS instruction: \(m)\nFrom: (\(step.startLocation!.latitude); \(step.startLocation!.longitude))\nTo: (\(step.endLocation!.latitude); \(step.endLocation!.longitude))"
//        } else {
//            msg = "\(step.rawInstructions!)\nFrom: (\(step.startLocation!.latitude); \(step.startLocation!.longitude))\nTo: (\(step.endLocation!.latitude); \(step.endLocation!.longitude))"
//        }
//        let alert = UIAlertController(title: "PXGoogleDirectionsSample", message: msg, preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//}
//
//extension ResultViewController: UITableViewDelegate {
//}
