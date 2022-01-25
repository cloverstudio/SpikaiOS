//
//  TestRepository+User.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import Foundation
import Combine

extension TestRepository {
    
    func authenticateUser(telephoneNumber: String, deviceId: String, countryCode: String) -> AnyPublisher<AuthResponseModel, Error> {
        return Fail<AuthResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func verifyCode(code: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
        return Fail<AuthResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func saveUserInfo(user: AppUser, device: Device) {
        print(user)
        print(device)
    }
    
    func getUsers() -> Future<[User], Error> {
        let users = [User(loginName: "Ivan", localName: "Ivan"),
                     User(loginName: "Luka", localName: "Luka")]
        return Future { promise in promise(.success(users))}
    }
    
    func saveUser(_ user: User) -> Future<User, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func addUserToChat(chat: Chat, user: User) -> Future<Chat, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func getUsersForChat(chat: Chat) -> Future<[User], Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
}
