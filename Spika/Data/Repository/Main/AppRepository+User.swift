//
//  AppRepository+User.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import Foundation
import Combine
import CryptoKit

extension AppRepository {
    
    func authenticateUser(telephoneNumber: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
        print("Phone number SHA256: ", telephoneNumber.getSHA256())
        let resources = Resources<AuthResponseModel, AuthRequestModel>(
            path: Constants.Endpoints.authenticateUser,
            requestType: .POST,
            bodyParameters: AuthRequestModel(
                telephoneNumber: telephoneNumber,
                telephoneNumberHashed: telephoneNumber.getSHA256(),
                deviceId: deviceId),
            httpHeaderFields: nil,
            queryParameters: nil
        )
        return networkService.performRequest(resources: resources)
    }
    
    func verifyCode(code: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
        let resources = Resources<AuthResponseModel, VerifyCodeRequestModel>(
            path: Constants.Endpoints.verifyCode,
            requestType: .POST,
            bodyParameters: VerifyCodeRequestModel(code: code, deviceId: deviceId),
            httpHeaderFields: nil,
            queryParameters: nil
        )
        print("resources are: ", resources)
        return networkService.performRequest(resources: resources)
    }
    
    func updateUser(username: String?, avatarURL: String?, telephoneNumber: String?, email: String?) -> AnyPublisher<UserResponseModel, Error>{
        
        guard let accessToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken)
        else {return Fail<UserResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<UserResponseModel, UserRequestModel>(
            path: Constants.Endpoints.userInfo,
            requestType: .PUT,
            bodyParameters: UserRequestModel(telephoneNumber: telephoneNumber, emailAddress: email, displayName: username, avatarUrl: avatarURL),
            httpHeaderFields: ["accesstoken" : accessToken])
        return networkService.performRequest(resources: resources)
    }
    
    func saveUserInfo(user: User, device: Device) {
        let defaults = UserDefaults.standard
        defaults.set(user.id, forKey: Constants.UserDefaults.userId)
        defaults.set(user.telephoneNumber, forKey: Constants.UserDefaults.userPhoneNumber)
        defaults.set(device.id, forKey: Constants.UserDefaults.deviceId)
        defaults.set(device.token, forKey: Constants.UserDefaults.accessToken)
    }
    
    func getMyUserId() -> Int {
        return UserDefaults.standard.integer(forKey: Constants.UserDefaults.userId)
    }
    
    func getUsers() -> Future<[LocalUser], Error> {
        return databaseService.userEntityService.getUsers()
    }
    
    func saveUser(_ user: LocalUser) -> Future<LocalUser, Error> {
        return databaseService.userEntityService.saveUser(user)
    }
    
    func saveUsers(_ users: [LocalUser]) -> Future<[LocalUser], Error> {
        return databaseService.userEntityService.saveUsers(users)
    }
    
    func uploadWholeFile(data: Data) -> (publisher: PassthroughSubject<UploadChunkResponseModel, Error>, totalChunksNumber: Int) {
        
        let dataLen: Int = data.count
        let chunkSize: Int = ((1024) * 4)
        let fullChunks = Int(dataLen / chunkSize)
        let totalChunks: Int = fullChunks + (dataLen % 1024 != 0 ? 1 : 0)
        let clientId = UUID().uuidString
        var hasher = SHA256()
        var hash: String?
        let chunkPublisher = PassthroughSubject<UploadChunkResponseModel, Error>()
    
        for chunkCounter in 0..<totalChunks {
            var chunk:Data
            let chunkBase: Int = chunkCounter * chunkSize
            var diff = chunkSize
            if(chunkCounter == totalChunks - 1) {
                diff = dataLen - chunkBase
            }
            
            let range:Range<Data.Index> = chunkBase..<(chunkBase + diff)
            chunk = data.subdata(in: range)
            
            hasher.update(data: chunk)
            if chunkCounter == totalChunks - 1 {
                hash = hasher.finalize().compactMap { String(format: "%02x", $0)}.joined()
            }
            
            uploadChunk(chunk: chunk.base64EncodedString(), offset: chunkBase/chunkSize, total: totalChunks, size: dataLen, mimeType: "image/*", fileName: "nameOfFile", clientId: clientId, type: "avatar", fileHash: hash, relationId: 1).sink { completion in
                switch completion {
                case let .failure(error):
                    print("Failure error", error)
                    chunkPublisher.send(completion: .failure(NetworkError.chunkUploadFail))
                case .finished:
                    break
                }
            } receiveValue: { uploadFileResponseModel in
                chunkPublisher.send(uploadFileResponseModel)
            }.store(in: &subs)
        }
        
        return (chunkPublisher, totalChunks)
    }
    
    func uploadChunk(chunk: String, offset: Int, total: Int, size: Int, mimeType: String, fileName: String, clientId: String, type: String, fileHash: String? = nil, relationId: Int) -> AnyPublisher<UploadChunkResponseModel, Error> {

        guard let accessToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken)
        else {return Fail<UploadChunkResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<UploadChunkResponseModel, UploadChunkRequestModel>(
            path: Constants.Endpoints.uploadFiles,
            requestType: .POST,
            bodyParameters: UploadChunkRequestModel(chunk: chunk, offset: offset, total: total, size: size, mimeType: mimeType, fileName: fileName, clientId: clientId, type: type, fileHash: fileHash, relationId: relationId),
            httpHeaderFields: ["accesstoken" : accessToken]) //access token
        
        return networkService.performRequest(resources: resources)
    }
    
    func postContacts(hashes: [String]) -> AnyPublisher<ContactsResponseModel, Error> {
        guard let accessToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken)
        else { return Fail<ContactsResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let contacts = ContactsRequestModel(contacts: hashes)
        let resources = Resources<ContactsResponseModel, ContactsRequestModel>(
            path: Constants.Endpoints.contacts,
            requestType: .POST,
            bodyParameters: contacts,
            httpHeaderFields: ["accesstoken" : accessToken])
        return networkService.performRequest(resources: resources)
    }
    
    func getContacts(page: Int) -> AnyPublisher<ContactsResponseModel, Error> {
        guard let accessToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken)
        else { return Fail<ContactsResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<ContactsResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.contacts,
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken],
            queryParameters: ["page": String(page)]
        )
        return networkService.performRequest(resources: resources)
    }
}
