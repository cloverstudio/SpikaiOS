//
//  CurrentPrivateChatView.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import UIKit

class CurrentChatView: UIView, BaseView {
    
    let messagesTableView = UITableView(frame: .zero, style: .grouped)
    let messageInputView = MessageInputView()
    private let newMessagesLabel = CustomLabel(text: "You have new messages.", textSize: 16, textColor: .textPrimary, fontName: .MontserratMedium)
    private let downArrowImageView = UIImageView(image: UIImage(safeImage: .downArrow))
    let scrollToBottomStackView = UIStackView()
    
    private var messageInputViewBottomConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(messagesTableView)
        addSubview(scrollToBottomStackView)
        scrollToBottomStackView.addArrangedSubview(newMessagesLabel)
        scrollToBottomStackView.addArrangedSubview(downArrowImageView)
        addSubview(messageInputView)
    }
    
    func styleSubviews() {
        messagesTableView.separatorStyle  = .none
        messagesTableView.keyboardDismissMode = .interactive
        messagesTableView.rowHeight = UITableView.automaticDimension

        messagesTableView.backgroundColor = .clear
        messagesTableView.showsHorizontalScrollIndicator = false
        
        scrollToBottomStackView.backgroundColor = .chatBackground
        scrollToBottomStackView.layer.cornerRadius = 10
        scrollToBottomStackView.layer.shadowOpacity = 0.25
        scrollToBottomStackView.layer.shadowRadius = 4
        scrollToBottomStackView.layer.shadowOffset = CGSize(width: 0, height: 4)
        downArrowImageView.contentMode = .scaleAspectFit
        
        backgroundColor = .primaryBackground
    }
    
    func positionSubviews() {        
        messagesTableView.anchor(top: topAnchor, leading: leadingAnchor, bottom: messageInputView.topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left:0, bottom: 0, right: 0))
        
        scrollToBottomStackView.anchor(bottom: messagesTableView.bottomAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0))
        scrollToBottomStackView.centerXToSuperview()
        scrollToBottomStackView.constrainHeight(36)
        
        scrollToBottomStackView.isLayoutMarginsRelativeArrangement = true
        scrollToBottomStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        scrollToBottomStackView.setCustomSpacing(8, after: newMessagesLabel)
        
    
        messageInputView.anchor(leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        messageInputViewBottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        messageInputViewBottomConstraint.isActive = true
    }
    
    func setupBindings() {
        let cells = [TextMessageTableViewCell.self,
                     ImageMessageTableViewCell.self,
                     FileMessageTableViewCell.self,
                     AudioMessageTableViewCell.self,
                     VideoMessageTableViewCell.self,
                     DeletedMessageTableViewCell.self]
        
        cells.forEach { cell in
            messagesTableView.register(cell, forCellReuseIdentifier: MessageSender.me.reuseIdentifierPrefix + String(describing: cell))
            messagesTableView.register(cell, forCellReuseIdentifier: MessageSender.friend.reuseIdentifierPrefix + String(describing: cell))
            messagesTableView.register(cell, forCellReuseIdentifier: MessageSender.group.reuseIdentifierPrefix + String(describing: cell))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            messageInputViewBottomConstraint.constant = -keyboardSize.height + 30
            var indexPath: IndexPath?
            if let lastCell = messagesTableView.visibleCells.last {
                indexPath = messagesTableView.indexPath(for: lastCell)
            }
            DispatchQueue.main.async { [weak self] in
                self?.layoutIfNeeded()
                guard let indexPath else { return }
                self?.messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        messageInputViewBottomConstraint.constant = 0
        DispatchQueue.main.async { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
    
    func handleScrollToBottomButton(show: Bool, number: Int) {
        scrollToBottomStackView.isHidden = !show
        newMessagesLabel.isHidden = number == 0
        newMessagesLabel.text = "You have \(number) new message" + (number > 1 ? "s" : "") // todo: - localization
    }
}


