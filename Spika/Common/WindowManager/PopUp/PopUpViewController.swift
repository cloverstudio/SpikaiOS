//
//  ErrorAlertViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.11.2022..
//

import UIKit
import Combine

class PopUpViewController: BaseViewController {
    let popUpView: UIView
    let publisher: PassthroughSubject<PopUpPublisherType, Never>
    
    init(_ type: PopUpType, publisher: PassthroughSubject<PopUpPublisherType, Never>) {
        self.publisher = publisher
        switch type {
        case .oneSec(let type):
            popUpView = OneSecPopUpView(type: type)
            publisher.send(.dismiss(after: 1))
        case .errorMessage(let message):
            popUpView = ErrorMessageView(message: message)
            publisher.send(.dismiss(after: 3))
        }
        super.init()

        view.addSubview(popUpView)
        popUpView.centerInSuperview()
        
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PopUpViewController {
    func setupBindings() {
        (popUpView as? AlertView)?
            .tapPublisher
            .sink(receiveValue: { [weak self] selectedIndex in
                self?.publisher.send(.alertViewTap(selectedIndex))
            }).store(in: &subscriptions)
    }
}
