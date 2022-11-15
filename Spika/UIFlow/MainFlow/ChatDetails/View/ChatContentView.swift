//
//  ChatContentView.swift
//  Spika
//
//  Created by Vedran Vugrin on 11.11.2022..
//

import UIKit

class ChatContentView: UIView, BaseView {
    
    let chatImage = UIImageView()
    let chatName = CustomLabel(text: "Group", textColor: UIColor.primaryColor, fontName: .MontserratSemiBold)
    
    let sharedMediaOptionButton = NavView(text: "Shared Media, Links and Docs")
    let chatSearchOptionButton = NavView(text: "Chat search")
    let callHistoryOptionButton = NavView(text: "Call history")
    
    let notesOptionButton = NavView(text: "Notes")
    let favoriteMessagesOptionButton = NavView(text: "Favorites")
    
    let pinChatSwitchView = SwitchView(text: "Pin chat")
    let muteSwitchView = SwitchView(text: "Mute")
    
    let chatMembersView = ChatMembersView(contactsEditable: true)
    
    let blockLabel = CustomLabel(text: "Block", textSize: 14, textColor: .appRed)
    let reportLabel = CustomLabel(text: "Report", textSize: 14, textColor: .appRed)
    
    lazy var mainStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    } ()
    
    lazy var labelStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        positionSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addSubviews() {
        self.addSubview(chatImage)
        self.addSubview(chatName)
        self.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(sharedMediaOptionButton)
        mainStackView.addArrangedSubview(chatSearchOptionButton)
        mainStackView.addArrangedSubview(callHistoryOptionButton)
        
        mainStackView.addArrangedSubview(notesOptionButton)
        mainStackView.addArrangedSubview(favoriteMessagesOptionButton)
        
        mainStackView.addArrangedSubview(pinChatSwitchView)
        mainStackView.addArrangedSubview(muteSwitchView)
        
        mainStackView.addArrangedSubview(chatMembersView)
        
        mainStackView.addArrangedSubview(self.labelStackView)
        labelStackView.addArrangedSubview(blockLabel)
        labelStackView.addArrangedSubview(reportLabel)
    }
    
    func styleSubviews() {
        chatImage.image = UIImage(safeImage: .testImage)
        chatImage.layer.cornerRadius = 50
        chatImage.contentMode = .scaleAspectFill
        chatImage.clipsToBounds = true
    }
    
    func positionSubviews() {
        chatImage.anchor(top: self.topAnchor, padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0), size: CGSize(width: 100, height: 100))
        chatImage.centerXToSuperview()
        
        chatName.anchor(top: chatImage.bottomAnchor, padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        chatName.centerXToSuperview()
        
        mainStackView.anchor(top: chatName.bottomAnchor,
                             leading: self.leadingAnchor,
                             bottom: self.bottomAnchor,
                             trailing: self.trailingAnchor,
                             padding: UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0))

        
        blockLabel.constrainHeight(80)
    }
    
}
