//
//  MessageActionsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 18.01.2023..
//

import Foundation
import UIKit

class MessageActionsView: UIView {
    let reactionsStackview = CustomStackView(axis: .horizontal, distribution: .fillEqually, alignment: .center)
    let actionsStackview = CustomStackView(axis: .vertical, distribution: .fillEqually)
    private let actions: [MessageAction]
    private let reactionsEmojis: [String]
    
    init(reactions: [String], actions: [MessageAction]) {
        self.actions = actions
        self.reactionsEmojis = reactions
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageActionsView: BaseView {
    func addSubviews() {
        addSubview(reactionsStackview)
        addSubview(actionsStackview)
        
        reactionsEmojis.forEach { emoji in
            let emojiLabel = CustomLabel(text: emoji, textSize: 32, fontName: .MontserratSemiBold, alignment: .center)
            reactionsStackview.addArrangedSubview(emojiLabel)
        }

        actions.forEach { action in
            let contextMenuAction = ContextMenuActionView(messageAction: action)
            actionsStackview.addArrangedSubview(contextMenuAction)
        }
    }
    
    func styleSubviews() {
        backgroundColor = .secondaryBackground
    }
    
    func positionSubviews() {
        reactionsStackview.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        reactionsStackview.constrainHeight(80)
        
        actionsStackview.anchor(top: reactionsStackview.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
}
