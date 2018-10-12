//
//  ViewController.swift
//  TestMap
//
//  Created by Valera Kutuzov on 08/10/2018.
//  Copyright © 2018 EPAM. All rights reserved.
//

import UIKit
import CoreData

class PointsViewController: UITableViewController {
    
    var locations: [LocationsBasic] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Network.getLocations({ result in
            DispatchQueue.main.async {
                if !result {
                    self.showAlert()
                }
                self.loadLocations()
            }
        })
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadLocations()
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Alert", message: "Connection error", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        OperationQueue.main.addOperation({
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func loadLocations() {
        self.locations = DataManager.shared.getLocations()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Default") else {
            let cell = UITableViewCell.init()
            return cell
        }
        cell.textLabel?.text = locations[indexPath.row].name
        cell.detailTextLabel?.text = locations[indexPath.row].notes
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? MapViewController,
            let cellName = (sender as? UITableViewCell)?.textLabel?.text,
            let location = DataManager.shared.findObjectWithPredicate(cellName) as? LocationsBasic else {
            return
        }
        vc.selectedCell = location
    }

}

