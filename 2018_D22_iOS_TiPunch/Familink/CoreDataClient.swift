//
//  CoreDataClient.swift
//  Familink
//
//  Created by formation12 on 29/01/2019.
//  Copyright © 2019 ti.punch. All rights reserved.
//

import CoreData
import UIKit

class CoreDataClient{
    static let instance = CoreDataClient()

    func getContacts() -> [Contact] {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        
        return (try? context.fetch(fetchRequest)) ?? []
        
    }
}
