//
//  HomeView.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit

class HomeView: UIView, BaseView {
    
    let detailsButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Has to be implemented as it is required but will never be used")
    }
    
    func addSubviews() {
        addSubview(detailsButton)
    }
    
    func styleSubviews() {
        backgroundColor = .white
        
        detailsButton.setTitle("Details", for: .normal)
        detailsButton.setTitleColor(UIColor.blue, for: .normal)
    }
    
    func positionSubviews() {
        detailsButton.centerInSuperview()
    }
}
