//
//  Repository.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Combine

protocol Repository {
    // this is test endpoint, needs to be deleted in future
    func getPosts() -> AnyPublisher<[Post], Error>
    func createChat(_ chat: Chat) -> Future<Chat, Error>
    func getChats() -> Future<[Chat], Error>
    func updateChat(_ chat: Chat) -> Future<Chat, Error>
    func getUsers() -> Future<[User], Error>
    func saveUser(_ user: User) -> Future<User, Error>
    func addUserToChat(chat: Chat, user: User) -> Future<Chat, Error>
    func getUsersForChat(chat: Chat) -> Future<[User], Error>
    func saveMessage(_ message: Message) -> Future<Message, Error>
    func getMessagesForChat(chat: Chat) -> Future<[Message], Error>
}
