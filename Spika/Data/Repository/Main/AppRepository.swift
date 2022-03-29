//
//  AppRepository.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Combine

class AppRepository: Repository {

    let networkService: NetworkService
    let databaseService: DatabaseService
    var subs = Set<AnyCancellable>()
    
    
    init(networkService: NetworkService, databaseService: DatabaseService) {
        self.networkService = networkService
        self.databaseService = databaseService
    }
    
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken)
    }
    
    func getMyDeviceId() -> Int {
        return UserDefaults.standard.integer(forKey: Constants.UserDefaults.deviceId)
    }
    
    func getPosts() -> AnyPublisher<[Post], Error> {
        let resources = Resources<[Post], EmptyRequestBody>(
            path: Constants.Endpoints.getPosts,
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: nil,
            queryParameters: nil
        )
        return networkService.performRequest(resources: resources)
    }
    
}
