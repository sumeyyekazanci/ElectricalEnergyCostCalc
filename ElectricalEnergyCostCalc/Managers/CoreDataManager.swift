//
//  CoreDataManager.swift
//  ElectricalEnergyCostCalc
//
//  Created by Sümeyye Kazancı on 22.08.2022.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static var shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
           
            let container = NSPersistentContainer(name: "ElectricalEnergy")
        
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        
        // MARK: - Core Data Saving support
        
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func user(serviceNumber: String) -> User {
        let user = User(context: persistentContainer.viewContext)
        user.serviceNumber = serviceNumber
        return user
    }
    
    func consumption(consumption: Double, date: String, user: User) -> Consumption{
        let cons = Consumption(context: persistentContainer.viewContext)
        cons.value = consumption
        cons.date = date
        user.addToConsumption(cons)
        return cons
    }
    
    func getUser(name: String) -> User? {
        let request = NSFetchRequest<User>(entityName: "User")
        request.predicate = NSPredicate(format: "serviceNumber == %@", name)
        do {
            return try persistentContainer.viewContext.fetch(request).first
        }catch {
            print("Error while fetch user")
            return nil
        }
    }
    
    func users() -> [User] {
      let request: NSFetchRequest<User> = User.fetchRequest()
      var fetchedUsers: [User] = []
      do {
         fetchedUsers = try persistentContainer.viewContext.fetch(request)
      } catch let error {
         print("Error fetching users \(error)")
      }
      return fetchedUsers
    }
    
    func consumptions(user: User) -> [Consumption] {
      let request: NSFetchRequest<Consumption> = Consumption.fetchRequest()
      request.predicate = NSPredicate(format: "user = %@", user)
      request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
      var fetchedData: [Consumption] = []
      do {
        fetchedData = try persistentContainer.viewContext.fetch(request)
      } catch let error {
        print("Error fetching data \(error)")
      }
      return fetchedData
    }
}


