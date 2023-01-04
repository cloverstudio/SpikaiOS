//
//  ChatDetailsViewModel.swift
//  Spika
//
//  Created by Vedran Vugrin on 10.11.2022..
//

import UIKit
import Combine

class ChatDetailsViewModel: BaseViewModel {
    let room: CurrentValueSubject<Room,Never>
    
    private let updateContacts = PassthroughSubject<[Int64],Never>()
    
    init(repository: Repository, coordinator: Coordinator, room: CurrentValueSubject<Room,Never>) {
        self.room = room
        super.init(repository: repository, coordinator: coordinator)
        self.setupBindings()
    }
    
    func setupBindings() {
        self.updateContacts
            .flatMap { [weak self] userIds in
                guard let self = self else {
                    return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken).eraseToAnyPublisher()
                }
                return self.repository.updateRoomUsers(roomId: self.room.value.id, userIds: userIds)
            }
            .sink { [weak self] c in
                switch c {
                case .failure(_):
                    self?.getAppCoordinator()?.showError(message: .getStringFor(.somethingWentWrongAddingUsers))
                case.finished:
                    return
                }
            } receiveValue: { [weak self] responseModel in
                guard let room = responseModel.data?.room else { return }
                self?.updateRoom(room: room)
            }.store(in: &self.subscriptions)
    }
    
    func muteUnmute(mute: Bool) {
        self.repository
            .muteUnmuteRoom(roomId: self.room.value.id, mute: mute)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                let roomName = self.room.value.name ?? String(self.room.value.id)

                switch completion {
                case .finished:
                    break
                case .failure(_):
                    let message: String = mute ? .getStringFor(.somethingWentWrongMutingRoom) : .getStringFor(.somethingWentWrongUnmutingRoom)
                    self.getAppCoordinator()?
                        .showError(message: message)
                    //TODO: Reset Room muted state & observer
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func onAddNewUser() {
        let usersSelected = PassthroughSubject<[User],Never>()
        self.getAppCoordinator()?.presentUserSelection(preselectedUsers: self.room.value.users.map { $0.user }, usersSelectedPublisher: usersSelected)

        usersSelected
            .map { [unowned self] newUsers in
                return self.room.value.users.map { $0.userId } + newUsers.map { $0.id }
            }
            .subscribe(self.updateContacts)
            .store(in: &self.subscriptions)
    }
    
    func removeUser(user: User) {
        var userIds = self.room.value.users.map { $0.userId }
        userIds.removeAll(where: { $0 == user.id })
        self.updateContacts.send(userIds)
    }
    
    func updateRoom(room: Room) {
        self.repository
            .updateRoomUsers(room: room )
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.allroomsprinter()
                case .failure(_):
                    break
                }
            } receiveValue: { [weak self] room in
                self?.room.send(room)
            }.store(in: &self.subscriptions)
    }
    
    func deleteRoomComfirmed() {
        self.repository.deleteOnlineRoom(forRoomId: self.room.value.id)
            .sink { [weak self] completion in
                switch completion {
                case .failure(_):
                    self?.getAppCoordinator()?.showError(message: .getStringFor(.somethingWentWrongDeletingTheRoom))
                case.finished:
                    guard let room = self?.room.value else { return }
                    self?.deleteLocalRoom(room: room)
                    return
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func deleteLocalRoom(room: Room) {
        self.repository.deleteLocalRoom(roomId: room.id)
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] c in
                switch c {
                case .failure(_):
                    self?.getAppCoordinator()?.showError(message: .getStringFor(.somethingWentWrongDeletingTheRoom))
                case.finished:
                    self?.getAppCoordinator()?.popTopViewController()
                    self?.getAppCoordinator()?.popTopViewController()
                    return
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func deleteRoom() {
        self.getAppCoordinator()?.showAlertView(title: .getStringFor(.deleteTheRoom),
                                                message: .getStringFor(.deleteTheRoom),
                                                buttons: [AlertViewButton.regular(title: .getStringFor(.cancel)),
                                                          AlertViewButton.regular(title: .getStringFor(.delete))])
        .sink(receiveValue: { type in
            switch type {
            case .dismiss:
                ()
            case .alertViewTap(let index):
                guard index == 1 else { return }
                self.deleteRoomComfirmed()
            }
        }).store(in: &self.subscriptions)
    }
    
    deinit {
//        print("Deinit Works")
    }
    
}
