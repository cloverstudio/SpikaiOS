////
////  TestRepository+User.swift
////  AppTests
////
////  Created by Marko on 27.10.2021..
////
//
//import Foundation
//import UIKit
//import Combine
//
//extension TestRepository {
//    
//    func fetchMyUserDetails() -> AnyPublisher<AuthResponseModel, Error> {
//        return Fail<AuthResponseModel, Error>(error: NetworkError.badURL)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func authenticateUser(telephoneNumber: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
//        return Fail<AuthResponseModel, Error>(error: NetworkError.badURL)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func verifyCode(code: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
//        return Fail<AuthResponseModel, Error>(error: NetworkError.badURL)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func saveUserInfo(user: User, device: Device?) {
//        print(user)
//    }
//    
//    func getMyUserId() -> Int64 {
//        999
//    }
//    
//    func getAccessToken() -> String? {
//        "pferde"
//    }
//    
//    func getMyDeviceId() -> Int64 {
//        -1
//    }
//    
//    func getLocalUser(withId id: Int64) -> Future<User, Error> {
//        return Future { promise in promise(.failure(DatabaseError.unknown))}
//    }
//    
//    func getLocalUsers() -> Future<[User], Error> {
//        return Future { promise in promise(.failure(DatabaseError.unknown))}
//    }
//    
//    func saveUser(_ user: User) -> Future<User, Error> {
//        Future { promise in promise(.failure(DatabaseError.noSuchRecord))}
//    }
//    
//    func saveUsers(_ user: [User]) -> Future<[User], Error> {
//        Future { promise in promise(.failure(DatabaseError.noSuchRecord))}
//    }
//        
//    func updateUser(username: String?, avatarFileId: Int64?, telephoneNumber: String?, email: String?) -> AnyPublisher<UserResponseModel, Error> {
//        // TODO: - add tests
//        return Fail<UserResponseModel, Error>(error: NetworkError.badURL)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func postContacts(hashes: [String]) -> AnyPublisher<ContactsResponseModel, Error> {
//        return Fail<ContactsResponseModel, Error>(error: NetworkError.badURL)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func getContacts(page: Int) -> AnyPublisher<ContactsResponseModel, Error> {
//        return Fail<ContactsResponseModel, Error>(error: NetworkError.badURL)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func saveContacts(_ contacts: [FetchedContact]) -> Future<[FetchedContact], Error> {
//        Future { promise in promise(.failure(DatabaseError.noSuchRecord))}
//    }
//    
//    func getContact(phoneNumber: String) -> Future<FetchedContact, Error> {
//        Future { promise in promise(.failure(DatabaseError.noSuchRecord))}
//    }
//    
//    func updateUsersWithContactData(_ users: [User]) -> Future<[User], Error> {
//        Future { promise in promise(.failure(DatabaseError.noSuchRecord))}
//    }
//}
