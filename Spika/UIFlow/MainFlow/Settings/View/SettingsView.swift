//
//  SettingsView.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

class SettingsView: UIView, BaseView {
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(titleLabel)
    }
    
    func styleSubviews() {
        titleLabel.text = "Settings"
    }
    
    func positionSubviews() {
        titleLabel.centerInSuperview()
    }
    
}