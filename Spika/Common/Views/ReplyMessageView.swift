//
//  ReplyMessageView.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.03.2022..
//

import Foundation
import UIKit

class ReplyMessageView: UIView, BaseView {
    
    static let replyMessageViewHeight = 54.0
    static let replyMessageViewWidth  = 140.0
    
    private let senderNameLabel = CustomLabel(text: "", textSize: 9, textColor: .logoBlue, fontName: .MontserratSemiBold)
    private let messageLabel = CustomLabel(text: "", textSize: 9, textColor: .logoBlue, fontName: .MontserratMedium)
    private let leftImageView = UIImageView()
    private let voiceMessageView = UIView(backgroundColor: .systemPink)
    
    private let quotedMessage: MessageTest
        
    init(message: MessageTest) {
        quotedMessage = message
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(senderNameLabel)
        
        switch quotedMessage.messageType {
        case .photo:
            addSubview(leftImageView)
            addSubview(messageLabel)
        case .voice:
            addSubview(voiceMessageView)
        case .video:
            // TODO:
            addSubview(messageLabel)
            break
        case .text:
            addSubview(messageLabel)
            break
        }
    }
    
    func styleSubviews() {
        backgroundColor = .chatBackground
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        senderNameLabel.text = quotedMessage.senderName

        switch quotedMessage.messageType {
        case .text:
            messageLabel.text = quotedMessage.textOfMessage
            messageLabel.numberOfLines = 2
        case .video, .photo:
            messageLabel.text = "Media message"
            leftImageView.image = UIImage(named: "matejVida")
        case .voice:
            addSubview(voiceMessageView)
        }
    }
    
    func positionSubviews() {
        constrainHeight(ReplyMessageView.replyMessageViewHeight)
        constrainWidth(ReplyMessageView.replyMessageViewWidth)

        switch quotedMessage.messageType {
        case .text:
            senderNameLabel.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 10))
            
            messageLabel.anchor(top: senderNameLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 5, left: 12, bottom: 0, right: 10))
    
        case .photo, .video:
            leftImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0))
            leftImageView.constrainWidth(20)
            
            senderNameLabel.anchor(top: topAnchor, leading: leftImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 10))
            
            messageLabel.anchor(top: senderNameLabel.bottomAnchor, leading: leftImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 10))
        case .voice:
            senderNameLabel.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 10))
            
            voiceMessageView.anchor(top: senderNameLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left: 10, bottom: 10, right: 10))
        }
    }
}
