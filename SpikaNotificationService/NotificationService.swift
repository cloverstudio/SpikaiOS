//
//  NotificationService.swift
//  SpikaNotificationService
//
//  Created by Nikola Barbarić on 27.04.2022..
//

import UserNotifications
import CoreData
import Combine

class NotificationService: UNNotificationServiceExtension {
    
    var subs = Set<AnyCancellable>()
    let userDefaults = UserDefaults(suiteName: Constants.Networking.appGroupName)!
    let coreDataStack = CoreDataStack()
    lazy var repository = AppRepository(
        networkService: NetworkService(),
        databaseService: DatabaseService(userEntityService: UserEntityService(coreDataStack: coreDataStack),
                                         chatEntityService: ChatEntityService(coreDataStack: coreDataStack),
                                         messageEntityService: MessageEntityService(coreDataStack: coreDataStack),
                                         roomEntityService: RoomEntityService(coreDataStack: coreDataStack),
                                         coreDataStack: coreDataStack,
                                         userDefaults: self.userDefaults),
        userDefaults: self.userDefaults)

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            guard let jsonData = (bestAttemptContent.userInfo["message"] as? String)?.data(using: .utf8),
                  let message = try? JSONDecoder().decode(Message.self, from: jsonData)
            else {
                show(title: "Error", text: "Decoding error")
                return
            }
            saveMessage(message: message)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        show(title: "Error", text: "serviceExtensionTimeWillExpire")
    }
}

extension NotificationService {
    
    func sendDeliveredStatus(messageIds: [Int64]) {
        repository.sendDeliveredStatus(messageIds: messageIds).sink { c in
            
        } receiveValue: { response in
            guard let bestAttemptContent = self.bestAttemptContent,
                  let contentHandler = self.contentHandler
            else { return }
            contentHandler(bestAttemptContent)
        }.store(in: &subs)
    }
    
    func saveMessage(message: Message) {
        repository.saveMessages([message]).sink { [weak self] c in
            switch c {
            case .finished:
                break
            case let .failure(error):
                self?.show(title: "saving error", text: error.localizedDescription)
            }
        } receiveValue: { [weak self] messages in
            self?.getMessageNotificationInfo(message: messages.first!)
        }.store(in: &subs)
    }
    
    func getMessageNotificationInfo(message: Message) {
        repository.getNotificationInfoForMessage(message).sink { [weak self] c in
            switch c {
            case .finished:
                break
            case let .failure(error):
                self?.show(title: "get not info error", text: error.localizedDescription)
            }
        } receiveValue: { [weak self] info in
            self?.show(title: info.title, text: info.messageText)
        }.store(in: &subs)
    }
    
    func show(title: String, text: String) {
        guard let bestAttemptContent = self.bestAttemptContent,
              let contentHandler = self.contentHandler
        else { return }
        bestAttemptContent.title = title
        bestAttemptContent.body  = text
        contentHandler(bestAttemptContent)
    }
}
