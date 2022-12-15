//
//  AppRepository.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Combine
import CoreData

class AppRepository: Repository {

    let networkService: NetworkService
    let databaseService: DatabaseService
    var subs = Set<AnyCancellable>()
    let userDefaults = UserDefaults(suiteName: Constants.Networking.appGroupName)!
    
    let unreadRoomsPublisher = CurrentValueSubject<Int,Never>(0)
    
    init(networkService: NetworkService, databaseService: DatabaseService) {
        self.networkService = networkService
        self.databaseService = databaseService
//        print("repo init")
    }
    
    deinit {
//        print("repo deinit")
    }
    
    func getAccessToken() -> String? {
        return userDefaults.string(forKey: Constants.Database.accessToken)
    }
    
    func getMyDeviceId() -> Int64 {
        return Int64(userDefaults.integer(forKey: Constants.Database.deviceId))
    }
    
    func getMainContext() -> NSManagedObjectContext {
        return databaseService.coreDataStack.mainMOC
    }
}
