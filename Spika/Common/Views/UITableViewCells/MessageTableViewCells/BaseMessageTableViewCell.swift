//
//  BaseMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.07.2022..
//

import Foundation
import UIKit

enum MessageSender {
    case me
    case friend
    case group
}

class BaseMessageTableViewCell: UITableViewCell {
    
    let containerView = UIView()
    private let senderNameLabel = CustomLabel(text: "", textSize: 12, textColor: .textTertiary, fontName: .MontserratRegular, alignment: .left)
    private let senderPhotoImageview = UIImageView(image: UIImage(safeImage: .userImage))
    private let timeLabel = CustomLabel(text: "", textSize: 11, textColor: .textTertiary, fontName: .MontserratMedium)
    private let messageStateView = MessageStateView(state: .waiting)
    private let senderNameBottomConstraint = NSLayoutConstraint()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        guard let reuseIdentifier = reuseIdentifier else { return }
        let myReuseIdentifiers = [TextMessageTableViewCell.myTextReuseIdentifier,
                                  ImageMessageTableViewCell.myImageReuseIdentifier,
                                  FileMessageTableViewCell.myFileReuseIdentifier]
        let friendReuseIdentifiers = [TextMessageTableViewCell.friendTextReuseIdentifier,
                                      ImageMessageTableViewCell.friendImageReuseIdentifier,
                                      FileMessageTableViewCell.friendFileReuseIdentifier]
        let groupReuseIdentifiers = [TextMessageTableViewCell.groupTextReuseIdentifier,
                                     ImageMessageTableViewCell.groupImageReuseIdentifier,
                                     FileMessageTableViewCell.groupFileReuseIdentifier]
        if myReuseIdentifiers.contains(reuseIdentifier) {
            setupContainer(sender: .me)
        } else if friendReuseIdentifiers.contains(reuseIdentifier) {
            setupContainer(sender: .friend)
        } else if groupReuseIdentifiers.contains(reuseIdentifier) {
            setupContainer(sender: .group)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// TODO: - MY VS OTHER
extension BaseMessageTableViewCell: BaseView {
    func addSubviews() {
        contentView.addSubview(containerView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(messageStateView)
    }
    
    func styleSubviews() {
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        senderPhotoImageview.layer.cornerRadius = 10
        senderPhotoImageview.clipsToBounds = true
        senderPhotoImageview.isHidden = true
        timeLabel.isHidden = true
    }
    
    func positionSubviews() {
        
        containerView.widthAnchor.constraint(lessThanOrEqualToConstant: 276).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    }
    
    func setupContainer(sender: MessageSender) {
        containerView.backgroundColor = sender == .me ?  UIColor(hexString: "C8EBFE") : .chatBackground // TODO: ask nika for color
        messageStateView.isHidden = sender != .me
        
        switch sender {
        case .me:
            containerView.anchor(top: contentView.topAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 20))
            
            messageStateView.anchor(leading: containerView.trailingAnchor, bottom: containerView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 6))

            timeLabel.anchor(trailing: containerView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
        case .friend:
            containerView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, padding: UIEdgeInsets(top: 2, left: 20, bottom: 2, right: 0))
    
            timeLabel.anchor(leading: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
        case .group:
            contentView.addSubview(senderNameLabel)
            contentView.addSubview(senderPhotoImageview)
            
            senderNameLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: containerView.topAnchor, padding: UIEdgeInsets(top: 2, left: 68, bottom: 4, right: 0))

            containerView.anchor(leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, padding: UIEdgeInsets(top: 0, left: 60, bottom: 2, right: 0))
    
            senderPhotoImageview.anchor(bottom: containerView.bottomAnchor, trailing: containerView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 14), size: CGSize(width: 20, height: 20))
            
            timeLabel.anchor(leading: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
        }
    }
}

extension BaseMessageTableViewCell {
    
    override func prepareForReuse() {
        timeLabel.isHidden = true
        senderNameLabel.text = ""
        senderPhotoImageview.image = UIImage(safeImage: .userImage)
        senderPhotoImageview.isHidden = true
    }
    
    func updateCellState(to state: MessageState) {
        messageStateView.changeState(to: state)
    }
    
    func updateTime(to timestamp: Int64) {
        timeLabel.text = timestamp.convert(to: .HHmm)
    }
    
    func updateSender(name: String) {
        senderNameLabel.text = name
    }
    
    func updateSender(photoUrl: URL?) {
        senderPhotoImageview.isHidden = false
        senderPhotoImageview.kf.setImage(with: photoUrl, placeholder: UIImage(systemName: "apple")) // TODO: Change apple
    }
    
    func tapHandler() {
        timeLabel.isHidden.toggle()
    }
    
    func setTimeLabelVisible(_ value: Bool) {
        timeLabel.isHidden = !value
    }
}