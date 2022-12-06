//
//  UserSelectionView.swift
//  Spika
//
//  Created by Vedran Vugrin on 16.11.2022..
//

import Foundation
import UIKit

class UserSelectionView: UIView, BaseView {
    
    let mainVerticalStackView = CustomStackView(spacing: 20)
    
    lazy var topVerticakStackView: UIStackView = {
        let stack = CustomStackView()
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    } ()
    
    let topHorizontalStackView = CustomStackView(axis:.horizontal)
    
    let cancelLabel = CustomLabel(text: "Cancel", textSize: 18, textColor: .primaryColor, fontName: .MontserratSemiBold)
    let doneLabel = CustomLabel(text: "Done", textSize: 18, textColor: .primaryColor, fontName: .MontserratSemiBold)
    let titleLabel = CustomLabel(text: "Select users", textSize: 28, textColor: .textPrimaryAndWhite)
    let numberSelectedUsersLabel = CustomLabel(text: "0/100 selected", textSize: 11, textColor: .textPrimaryAndWhite)
    let searchBar = SearchBar(placeholder: "Search for contact", shouldShowCancel: false)
    let contactsTableView = ContactsTableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        self.addSubview(mainVerticalStackView)
        
        mainVerticalStackView.addArrangedSubview(self.topVerticakStackView)
        
        topVerticakStackView.addArrangedSubview(self.topHorizontalStackView)
        topHorizontalStackView.addArrangedSubview(self.cancelLabel)
        topHorizontalStackView.addArrangedSubview(self.doneLabel)
        
        topVerticakStackView.addArrangedSubview(self.titleLabel)
        topVerticakStackView.addArrangedSubview(self.numberSelectedUsersLabel)
        topVerticakStackView.addArrangedSubview(self.searchBar)
        
        mainVerticalStackView.addArrangedSubview(self.contactsTableView)
    }
    
    func styleSubviews() {}
    
    func positionSubviews() {
        self.mainVerticalStackView.constraint(with: UIEdgeInsets(top: 12, left: 0, bottom: -24, right: 0))
    }

}