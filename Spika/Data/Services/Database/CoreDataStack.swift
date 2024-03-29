//
//  CoreDataStack.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.04.2022..
//

import Foundation
import CoreData

class CoreDataStack: NSObject {
    
    private let moduleName = "CoreDatabase"
    
    override init() {
//        print("CoredataStack init")
    }
    
    deinit {
//        print("CoredataStack deinit")
    }
    
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: Constants.Database.databaseName)
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.moduleName)
        
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.Networking.appGroupName)!
        let storeName = "\(self.moduleName).sqlite"
        let storeUrl =  directory.appendingPathComponent(storeName)
        
        let description =  NSPersistentStoreDescription(url: storeUrl)
        
        //MARK: For light weight migration
        
        // description.shouldMigrateStoreAutomatically = true
        // description.shouldInferMappingModelAutomatically = true
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var mainMOC: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        moc.automaticallyMergesChangesFromParent = true
        return moc
    }()
    
//    lazy var backgroundMOC: NSManagedObjectContext = {
//        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        moc.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
//        moc.automaticallyMergesChangesFromParent = true
//        return moc
//    }()
}
