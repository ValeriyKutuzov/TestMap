//
//  DataManager.swift
//  TestMap
//
//  Created by Valera Kutuzov on 10/10/2018.
//  Copyright © 2018 EPAM. All rights reserved.
//

import UIKit
import CoreData

enum LocationFields: String {
    case name = "name"
    case latitude = "lat"
    case longtitude = "lng"
    case type = "type"
    case notes = "notes"
}

class DataManager: NSObject {
    
    var appDelegate: AppDelegate
    
    var context: NSManagedObjectContext
    
    var dateFormatter: DateFormatter
    
    static let shared = DataManager()
    
    override init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        context = appDelegate.persistentContainer.viewContext
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    }
}

extension DataManager {
    func getContext() -> NSManagedObjectContext {
        return context
    }
    
    func saveContext() {
        appDelegate.saveContext()
    }
    
    func setRefreshDate(_ dateString: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: kRefreshDateEntity)

        guard let date = dateFormatter.date(from:dateString) else {
            return
        }
        
        if let ent = (try? context.fetch(request))?.first as? RefreshDate {
            ent.date = date
            saveContext()
        }
        
        let entity = NSEntityDescription.entity(forEntityName: kRefreshDateEntity, in: context)
        let refreshDate = NSManagedObject(entity: entity!, insertInto: context)
        refreshDate.setValue(date, forKey: "date")
    }
    
    func checkRefreshDate(_ dateString: String) -> Bool {
        guard let date = dateFormatter.date(from:dateString) else {
            return false
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: kRefreshDateEntity)

        guard let ent = (try? context.fetch(request))?.first as? RefreshDate else {
            setRefreshDate(dateString)
            return true
        }
        if date.compare(ent.date!).rawValue == CFComparisonResult.compareGreaterThan.rawValue {
            ent.date = date
            saveContext()
            return true
        }
        return false
        
    }
    
    func addNewLocation(_ location: Any, type: String) {
        if let location = location as? NSDictionary,
            let pred = location.value(forKey: LocationFields.name.rawValue) as? String,
            self.findObjectWithPredicate(pred) == nil {

            let entity = NSEntityDescription.entity(forEntityName: kLocationBasicEntity, in: context)
            let newLocation = NSManagedObject(entity: entity!, insertInto: context)

            newLocation.setValue(location.value(forKey: LocationFields.name.rawValue), forKey: LocationFields.name.rawValue)
            newLocation.setValue(location.value(forKey: LocationFields.latitude.rawValue), forKey: LocationFields.latitude.rawValue)
            newLocation.setValue(location.value(forKey: LocationFields.longtitude.rawValue), forKey: LocationFields.longtitude.rawValue)
            newLocation.setValue(type, forKey: LocationFields.type.rawValue)
            self.saveContext()
        }
    }
    
    func getLocations() -> [LocationsBasic]{
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: kLocationBasicEntity)
            
        guard let result = (try? context.fetch(request)) as? [LocationsBasic] else {
            return []
        }
            
        return result
    }
    
    func findObjectWithPredicate(_ predicateName: String) -> NSFetchRequestResult? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: kLocationBasicEntity)
        request.predicate = NSPredicate(format: "name == %@", argumentArray: [predicateName])
        
        if let ent = (try? context.fetch(request))?.first {
            return ent as? NSFetchRequestResult
        }
        
        return nil
    }
}
