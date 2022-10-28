//
//  ConnectionIndicatorView.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.10.2022..
//

import UIKit

class ConnectionIndicatorView: UIView {
    init() {
        super.init(frame: .zero)
        layer.cornerRadius = 4
        constrainWidth(8)
        constrainHeight(8)
        changeColor(to: .appRed)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ConnectionIndicatorView {
    func changeColor(to color: UIColor) {
        backgroundColor = color
    }
}
