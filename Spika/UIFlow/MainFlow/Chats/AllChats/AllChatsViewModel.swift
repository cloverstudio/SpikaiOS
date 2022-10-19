//
//  ChatsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine

class AllChatsViewModel: BaseViewModel {
    
    func presentSelectUserScreen() {
        getAppCoordinator()?.presentSelectUserScreen()
    }
    
    func presentCurrentChatScreen(user: User) {
        getAppCoordinator()?.presentCurrentChatScreen(user: user)
    }
    
    func presentCurrentChatScreen(room: Room) {
        getAppCoordinator()?.presentCurrentChatScreen(room: room)
    }
    
    func getAllRooms() {
        repository.getAllRooms().sink { [weak self] completion in
            guard let _ = self else { return }
            print("get all rooms: ", completion)
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            guard let rooms = response.data?.list else { return }
            
            self.repository.saveLocalRooms(rooms: rooms).sink { c in
                print("Save room allCV: ", c)
            } receiveValue: { rooms in
                
            }.store(in: &self.subscriptions)
            print("rooms server: ", rooms.count)
        }.store(in: &subscriptions)
    }
    
    func getMyUserId() -> Int64 {
        return repository.getMyUserId()
    }
}
