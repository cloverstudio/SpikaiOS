//
//  EnterNumberView.swift
//  Spika
//
//  Created by Marko on 27.10.2021..
//

import UIKit

class EnterNumberView: UIView, BaseView {
    
    let logoImage = LogoImageView()
    let titleLabel = UILabel()
    let enterNumberTextField = EnterNumberTextField(placeholder: "Eg. 98726123", title: "Phone number")
    let nextButton = MainButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(logoImage)
        addSubview(titleLabel)
        addSubview(enterNumberTextField)
        addSubview(nextButton)
    }
    
    func styleSubviews() {
        titleLabel.font = UIFont(name: "Montserrat-Medium", size: 14)
        titleLabel.text = "Enter your phone number to start using Spika"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.setEnabled(false)
        
        enterNumberTextField.delegate = self
    }
    
    func positionSubviews() {
        logoImage.anchor(top: topAnchor, padding: UIEdgeInsets(top: 40, left: 0, bottom: 24, right: 0), size: CGSize(width: 72, height: 72))
        logoImage.centerX(inView: self)
        
        titleLabel.anchor(top: logoImage.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 24, left: 70, bottom: 50, right: 70))
        
        enterNumberTextField.anchor(top: titleLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 50, left: 30, bottom: 14, right: 30))
        
        nextButton.anchor(top: enterNumberTextField.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 14, left: 30, bottom: 0, right: 30))
        nextButton.constrainHeight(50)
        
        
    }
    
    func setCountryCode(code: String) {
        enterNumberTextField.countryNumberLabel.text = code
    }
    
    func getCountryCode(removePlus: Bool = false) -> String? {
        guard let code = enterNumberTextField.countryNumberLabel.text else { return nil }
        if removePlus {
            return String(code.dropFirst())
        }
        return code
    }
    
    func getFullNumber() -> String? {
        if let countryCode = getCountryCode(), let number = enterNumberTextField.getNumber() {
            return "\(countryCode)\(number)"
        }
        return nil
    }
    
}


extension EnterNumberView: EnterNumberTextFieldDelegate {
    func enterNumberTextField(_ enterNumberTextField: EnterNumberTextField, valueDidChange value: String) {
        nextButton.setEnabled(value.count > 0)
    }
}
