//
//  EnterVerifyCodeViewModel.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import Foundation
import Combine

class EnterVerifyCodeViewModel: BaseViewModel {
    
    let deviceId: String
    let phoneNumber: TelephoneNumber
    
    let resendSubject = CurrentValueSubject<Bool, Never>(false)
    
    init(repository: Repository, coordinator: Coordinator, deviceId: String, phoneNumber: TelephoneNumber) {
        self.deviceId = deviceId
        self.phoneNumber = phoneNumber
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func verifyCode(code: String) {
        networkRequestState.send(.started())
        repository.verifyCode(code: code, deviceId: deviceId).sink { [weak self] completion in
            guard let self else { return }
            self.networkRequestState.send(.finished)
            switch completion {
            case let .failure(error):
                self.showError("Could not auth user: \(error)")
            default: break
            }
        } receiveValue: { [weak self] authModel in
            guard let user = authModel.data?.user,
                  let device = authModel.data?.device,
                  let self
            else {
                self?.showError("No user or device response.")
                return
            }
            self.repository.saveUserInfo(user: user, device: device, telephoneNumber: self.phoneNumber)
            if user.displayName != "" && user.displayName != nil {
                self.presentHomeScreen()
            } else {
                self.presentEnterUsernameScreen()
            }
        }.store(in: &subscriptions)

    }
    
    func resendCode() {
        networkRequestState.send(.started())
        repository.authenticateUser(telephoneNumber: phoneNumber.getFullNumber(), deviceId: deviceId).sink { [weak self] completion in
            self?.networkRequestState.send(.finished)
            switch completion {
            case let .failure(error):
                self?.showError("Could not auth user: \(error)")
            default: break
            }
        } receiveValue: { [weak self] authResponse in
            self?.resendSubject.value = true
        }.store(in: &subscriptions)
    }
    
    private func presentEnterUsernameScreen() {
        getAppCoordinator()?.presentEnterUsernameScreen()
    }
    
    private func presentHomeScreen() {
        getAppCoordinator()?.presentHomeScreen(startSyncAndSSE: true)
    }
    
}
