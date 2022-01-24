//
//  ActionButton.swift
//  Spika
//
//  Created by Marko on 08.11.2021..
//

import UIKit

class ActionButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        setTitleColor(.primaryColor, for: .normal)
    }
    
}
