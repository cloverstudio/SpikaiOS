//
//  TestRepository+User.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import Foundation
import Combine

extension TestRepository {
    
    func authenticateUser(telephoneNumber: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
        return Fail<AuthResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func verifyCode(code: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
        return Fail<AuthResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func saveUserInfo(user: User, device: Device) {
        print(user)
    }
    
    func getMyUserId() -> Int {
        999
    }
    
    func getUsers() -> Future<[LocalUser], Error> {
        let users = [LocalUser(loginName: "Ivan", localName: "Ivan"),
                     LocalUser(loginName: "Luka", localName: "Luka")]
        return Future { promise in promise(.success(users))}
    }
    
    func saveUser(_ user: LocalUser) -> Future<LocalUser, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func saveUsers(_ user: [LocalUser]) -> Future<[LocalUser], Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func addUserToChat(chat: Chat, user: LocalUser) -> Future<Chat, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func getUsersForChat(chat: Chat) -> Future<[LocalUser], Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func uploadWholeFile(data: Data) -> (publisher: PassthroughSubject<UploadChunkResponseModel, Error>, totalChunksNumber: Int) {
        return (PassthroughSubject<UploadChunkResponseModel, Error>(), 0)
    }
    
    func uploadChunk(chunk: String, offset: Int, total: Int, size: Int, mimeType: String, fileName: String, clientId: String, type: String, fileHash: String?, relationId: Int) -> AnyPublisher<UploadChunkResponseModel, Error> {
        // TODO: - add tests
        return Fail<UploadChunkResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func updateUser(username: String?, avatarURL: String?, telephoneNumber: String?, email: String?) -> AnyPublisher<UserResponseModel, Error> {
        // TODO: - add tests
        return Fail<UserResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func postContacts(hashes: [String]) -> AnyPublisher<ContactsResponseModel, Error> {
        return Fail<ContactsResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getContacts(page: Int) -> AnyPublisher<ContactsResponseModel, Error> {
        return Fail<ContactsResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}
