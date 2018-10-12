//
//  Locations.swift
//  TestMap
//
//  Created by Valera Kutuzov on 10/10/2018.
//  Copyright © 2018 EPAM. All rights reserved.
//

import UIKit
import CoreData

let kLocationsURL = "http://bit.ly/test-locations"
let kLocationBasicEntity = "LocationsBasic"
let kRefreshDateEntity = "RefreshDate"

enum JSONFields: String {
    case locations = "locations"
    case updated = "updated"
}

enum LocationType: String {
    case basic = "basic"
    case user = "user"
}

class Network: NSObject {
    
    public class func getLocations(_ completion: @escaping  (Bool) -> Void) {
        guard let url = URL(string:kLocationsURL) else {
            completion(false)
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in
            
            guard data != nil,
                let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary else {
                    completion(false)
                    return
            }
            
            guard let dateString = jsonObj?.value(forKey: JSONFields.updated.rawValue) as? String,
                DataManager.shared.checkRefreshDate(dateString) else {
                    completion(true)
                    return
            }
            
            if let locationsArray = jsonObj!.value(forKey: JSONFields.locations.rawValue) as? NSArray {
                OperationQueue.main.addOperation({
                    updateLocations(locationsArray)
                    completion(true)
                })
            }
            completion(false)
            
        }).resume()
    }
    
    class func updateLocations(_ array: NSArray) {
        for location in array {
            DataManager.shared.addNewLocation(location, type: LocationType.basic.rawValue)
        }
    }
}

extension URLRequest {
    
    static func locationsBaseRequest(url: URL? =  nil) -> URLRequest? {
        
        guard let url = URL(string: kLocationsURL) else {
            return nil
        }
        
        let request = URLRequest(url: url)
        
        return request
    }
    
}
