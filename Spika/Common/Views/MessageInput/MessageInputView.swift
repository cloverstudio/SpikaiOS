//
//  MessageInputView.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.02.2022..
//

import Foundation
import UIKit
import Combine

enum MessageInputViewState {
    case send(message: String)
    case camera
    case microphone
    case emoji
    case files
    case library
    case scrollToReply(IndexPath)
}

class MessageInputView: UIStackView, BaseView {
    
    let inputViewTapPublisher = PassthroughSubject<MessageInputViewState, Never>()
    private var subscriptions = Set<AnyCancellable>()

    private let dividerLine = UIView()
    private lazy var inputTextAndControlsView = InputTextAndControlsView(publisher: inputViewTapPublisher)
    private let additionalOptionsView    = AdditionalOptionsView()
    let selectedFilesView = SelectedFilesView()
    var replyView: MessageReplyView?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupBindings()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(dividerLine)
        addArrangedSubview(inputTextAndControlsView)
    }
    
    func styleSubviews() {
        axis = .vertical
        dividerLine.backgroundColor = .navigation
    }
    
    func positionSubviews() {
        dividerLine.constrainHeight(0.5)
        dividerLine.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
}

// MARK: - Bindings

extension MessageInputView {
    
    func setupBindings() {
        
        additionalOptionsView.publisher.sink { [weak self] state in
//            self?.handleAdditionalOptions(state)
        }.store(in: &subscriptions)
    }
    
    func clean() {
        hideReplyView()
        hideSelectedFiles()
        hideAdditionalOptions()
    }
}

// MARK: - Additional options view

extension MessageInputView {
    func handleAdditionalOptions(_ state: AdditionalOptionsViewState) {
        self.hideAdditionalOptions()
        
        switch state {
        case .files:
            inputViewTapPublisher.send(.files)
        case .library:
            inputViewTapPublisher.send(.library)
        case .location:
            break
        case .contact:
            break
        }
    }
    func showAdditionalOptions() {
        if additionalOptionsView.superview == nil {
//            addSubview(additionalOptionsView)
//            additionalOptionsView.anchor(leading: leadingAnchor, bottom: dividerLine.topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
    }
    
    func hideAdditionalOptions() {
        if additionalOptionsView.superview != nil {
            additionalOptionsView.removeFromSuperview()
        }
    }
}

// MARK: - Selected files view

extension MessageInputView {
    func showSelectedFiles(_ files: [SelectedFile]) {
        if selectedFilesView.superview == nil {
            addSubview(selectedFilesView)
            
            selectedFilesView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            selectedFilesView.constrainHeight(120)
        }
        selectedFilesView.showFiles(files)
    }
    
    func hideSelectedFiles() {
        if selectedFilesView.superview != nil {
            selectedFilesView.removeFromSuperview()
        }
    }
}

extension MessageInputView {
    func showReplyView(senderName: String, message: Message, indexPath: IndexPath?) {
        hideReplyView()
        if replyView == nil {
            self.replyView = MessageReplyView(senderName: senderName, message: message,
                                              backgroundColor: .chatBackground,
                                              indexPath: indexPath, showCloseButton: true)
            replyBindings()
            guard let replyView = replyView else { return }
            insertArrangedSubview(replyView, at: 0)
        }
    }
    
    func hideReplyView() {
        replyView?.removeFromSuperview()
        replyView = nil
    }
    
    func replyBindings() {
        replyView?.closeButton.tap().sink(receiveValue: { [weak self] _ in
            self?.hideReplyView()
        }).store(in: &subscriptions)
        
        replyView?.containerView.tap().sink(receiveValue: { [weak self] _ in
            guard let indexPath = self?.replyView?.indexPath else { return }
            self?.inputViewTapPublisher.send(.scrollToReply(indexPath))
        }).store(in: &subscriptions)
    }
}
