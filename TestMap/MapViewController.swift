//
//  MapViewController.swift
//  TestMap
//
//  Created by Valera Kutuzov on 08/10/2018.
//  Copyright © 2018 EPAM. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    var basicLocations: [LocationsBasic] = []
    var mapView: GMSMapView?
    var selectedCell: LocationsBasic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.basicLocations = DataManager.shared.getLocations()
        self.loadMap()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func loadMap() {
        let camera = GMSCameraPosition.camera(withLatitude: selectedCell?.lat ?? basicLocations.first?.lat ?? 0, longitude: selectedCell?.lng ?? basicLocations.first?.lng ?? 0, zoom: 11.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView?.delegate = self
        view = mapView
        
        for loc in basicLocations {
            setMarkerWithLocation(location: loc)
        }
    }
    
    func setMarkerWithLocation(location: Any?) {
        if let loc = location as? LocationsBasic {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: loc.lat, longitude: loc.lng)
            marker.title = loc.name
            marker.snippet = loc.notes
            marker.map = mapView
            if loc.type == LocationType.user.rawValue {
                marker.icon = GMSMarker.markerImage(with: .blue)
            }
            if loc == selectedCell {
                mapView?.selectedMarker = marker
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        showNameAlert(coordinate)
    }

    func setNewMarker(_ name: String,coordinate: CLLocationCoordinate2D) {
        let loc = [LocationFields.name.rawValue: name,
                   LocationFields.latitude.rawValue: coordinate.latitude,
                   LocationFields.longtitude.rawValue: coordinate.longitude] as [String : Any]
        DataManager.shared.addNewLocation(loc, type: LocationType.user.rawValue)
        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = name
        marker.snippet = ""
        marker.map = mapView
        marker.icon = GMSMarker.markerImage(with: .blue)

    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
       showNotesAlert(marker)
    }
    
    func showNameAlert(_ coordinate: CLLocationCoordinate2D) {
        let alert = UIAlertController(title: "Set name", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter name"
        })
        
        let okAction = UIAlertAction(title: "Save", style: .default, handler: {_ in
            self.setNewMarker(alert.textFields?.first?.text ?? "", coordinate: coordinate)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showNotesAlert(_ marker: GMSMarker) {
        let alert = UIAlertController(title: "Notes", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter some notes"
        })
        
        let okAction = UIAlertAction(title: "Save", style: .default, handler: {_ in
            guard let name = marker.title,
                let ent = DataManager.shared.findObjectWithPredicate(name) as? LocationsBasic else {
                    return
            }
            ent.notes = alert.textFields?.first?.text
            DataManager.shared.saveContext()
            marker.snippet = alert.textFields?.first?.text
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
