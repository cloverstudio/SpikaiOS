//
//  EnterUsernameView.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.01.2022..
//

import Foundation
import UIKit

class EnterUsernameView: UIView, BaseView {
    
    let errorView = ErrorView(message: "Username already taken!")
    let profilePictureView = ImageViewWithIcon(image: UIImage(named: "logo")!, size: CGSize(width: 100, height: 100))
    private let usernameLabel = CustomLabel(text: "Username", textColor: .textTertiary, fontName: .MontserratMedium)
    let usernameTextfield = TextField(textPlaceholder: "Enter username")
    let nextButton = MainButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(errorView)
        addSubview(profilePictureView)
        addSubview(usernameLabel)
        addSubview(usernameTextfield)
        addSubview(nextButton)
    }
    
    func styleSubviews() {
        nextButton.setTitle("Next", for: .normal)
        nextButton.setEnabled(false)
    }
    
    func positionSubviews() {
        errorView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 16, left: 20, bottom: 0, right: 20))
        
        profilePictureView.anchor(top: topAnchor, padding: UIEdgeInsets(top: 75, left: 0, bottom: 0, right: 0))
        profilePictureView.centerXToSuperview()
        
        usernameLabel.anchor(top: profilePictureView.bottomAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 30, left: 30, bottom: 0, right: 0))
        
        usernameTextfield.anchor(top: usernameLabel.bottomAnchor, leading: usernameLabel.leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 30))
        usernameTextfield.constrainHeight(50)
        
        nextButton.anchor(top: usernameTextfield.bottomAnchor, leading: usernameTextfield.leadingAnchor, trailing: usernameTextfield.trailingAnchor, padding: UIEdgeInsets(top: 14, left: 0, bottom: 0, right: 0))
        nextButton.constrainHeight(50)
    }
    
    func setupBindings() {
        usernameTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let value = textField.text {
            nextButton.setEnabled(!value.isEmpty)
        }
    }
}
