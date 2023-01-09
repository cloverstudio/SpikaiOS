//
//  ChatContentView.swift
//  Spika
//
//  Created by Vedran Vugrin on 11.11.2022..
//

import UIKit

class ChatContentView: UIView, BaseView {
    
    let chatImage = ImageViewWithIcon(image:  UIImage(safeImage: .userImage),size: CGSize(width: 120, height: 120))
    
    let chatName = CustomLabel(text: .getStringFor(.group), textColor: UIColor.primaryColor, fontName: .MontserratSemiBold)
    
    let sharedMediaOptionButton = NavView(text: .getStringFor(.sharedMediaLinksDocs))
    let chatSearchOptionButton = NavView(text: .getStringFor(.chatSearch))
    let callHistoryOptionButton = NavView(text: .getStringFor(.callHistory))
    
    let notesOptionButton = NavView(text: .getStringFor(.notes))
    let favoriteMessagesOptionButton = NavView(text: .getStringFor(.favorites))
    
    let pinChatSwitchView = SwitchView(text: .getStringFor(.pinchat))
    let muteSwitchView = SwitchView(text: .getStringFor(.mute))
    
    let chatMembersView = ChatMembersView(contactsEditable: true)
    
    let blockLabel = CustomLabel(text: .getStringFor(.block), textSize: 14, textColor: .appRed)
    let reportLabel = CustomLabel(text: .getStringFor(.report), textSize: 14, textColor: .appRed)
    
    var deleteButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle(.getStringFor(.delete), for: .normal)
        btn.setTitleColor(.appRed, for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.titleLabel?.font = UIFont(name: CustomFontName.MontserratRegular.rawValue, size: 14)
        return btn
    } ()
    
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
        styleSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addSubviews() {
        self.addSubview(chatImage)
//        self.addSubview(self.cameraIcon)
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
        labelStackView.addArrangedSubview(deleteButton)
    }
    
    func styleSubviews() {
//        chatImage.image = UIImage(safeImage: .testImage)
//        chatImage.layer.cornerRadius = 60
//        chatImage.contentMode = .scaleAspectFill
//        chatImage.clipsToBounds = true
    }
    
    func positionSubviews() {
        chatImage.anchor(top: self.topAnchor, padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0), size: CGSize(width: 120, height: 120))
        chatImage.centerXToSuperview()
        
//        cameraIcon.centerX(self.chatImage, constant: 40)
//        cameraIcon.centerY(self.chatImage, constant: 40)
        chatImage.constrainWidth(120)
        chatImage.constrainHeight(120)
        
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
