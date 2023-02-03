//
//  ChatMembersView.swift
//  Spika
//
//  Created by Vedran Vugrin on 11.11.2022..
//

import UIKit
import Combine

final class ChatMembersView: UIView, BaseView {
    
    //MARK: - Variables
    let canAddNewMore: Bool
    
    let cellHeight: CGFloat = 80
    
    var viewIsExpanded = false
    
    var users: [RoomUser] = [] //TODO:  Add sort
    
    var tableViewHeightConstraint: NSLayoutConstraint!
    
    let onRemoveUser = PassthroughSubject<IndexPath,Never>()
    
    var subscriptions = Set<AnyCancellable>()
    
    let editable = CurrentValueSubject<Bool,Never>(false)
    
    //MARK: - UI
    lazy var mainStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    } ()
    
    lazy var horizontalTitleStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    } ()
    
    let titleLabel = CustomLabel(text: .getStringFor(.members), textSize: 22,
                                 textColor: .textPrimary,
                                 fontName: .MontserratSemiBold)
    
    lazy var addContactButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(safeImage: .plus), for: .normal)
        return button
    } ()
    
    lazy var showMoreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(.getStringFor(.showMore), for: .normal)
        button.setTitleColor(UIColor.primaryColor, for: .normal)
        button.addTarget(self, action: #selector(onShowMore), for: .touchUpInside)
        return button
    } ()
    
    lazy var tableView: ContactsTableView = {
        let tableView = ContactsTableView()
        tableView.isScrollEnabled = false
//        tableView.allowsSelection = false
        return tableView
    } ()
    
    
    //MARK: - Methods
    init(canAddNewMore: Bool) {
        self.canAddNewMore = canAddNewMore
        super.init(frame: CGRectZero)
        setupView()
        self.setupBinding()
        self.setupForInitialHeight()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBinding() {
        self.editable
            .sink { [weak self] isAdmin in
                self?.addContactButton.isHidden = !isAdmin
            }.store(in: &self.subscriptions)
    }
    
    func updateWithUsers(users: [RoomUser]) {
        self.users = users

        self.titleLabel.text = "\(users.count) " + .getStringFor(.members)
        self.tableView.reloadData()
        
        if self.viewIsExpanded {
            self.setupExpandedView()
        } else {
            self.setupForInitialHeight()
        }
    }
    
    func setupForInitialHeight() {
        if self.users.count <= 3 {
            self.tableViewHeightConstraint.constant = CGFloat(self.users.count) * self.cellHeight
            self.showMoreButton.isHidden = true
        } else {
            self.tableViewHeightConstraint.constant = 3 * self.cellHeight
            self.showMoreButton.isHidden = false
        }
        self.showMoreButton.setTitle(.getStringFor(.showMore), for: .normal)
    }
    
    func setupExpandedView() {
        self.tableViewHeightConstraint.constant = CGFloat(self.users.count) * self.cellHeight
        self.showMoreButton.setTitle(.getStringFor(.showLess), for: .normal)
    }
    
    func addSubviews() {
        self.addSubview(self.mainStackView)
        
        self.mainStackView.addArrangedSubview(self.horizontalTitleStackView)
        self.horizontalTitleStackView.addArrangedSubview(self.titleLabel)
        
        if self.canAddNewMore {
            self.horizontalTitleStackView.addArrangedSubview(self.addContactButton)
        }
        
        self.mainStackView.addArrangedSubview(self.tableView)
        self.mainStackView.addArrangedSubview(self.showMoreButton)
    }
    
    func styleSubviews() {
        self.tableViewHeightConstraint = self.tableView.heightAnchor.constraint(equalToConstant: cellHeight)
        self.tableViewHeightConstraint.isActive = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func positionSubviews() {
        self.mainStackView.fillSuperview()
        self.horizontalTitleStackView.constrainHeight(cellHeight)
    }
    
    @objc func onShowMore() {
        self.viewIsExpanded = !self.viewIsExpanded
        if self.viewIsExpanded {
            self.setupForInitialHeight()
        } else {
            self.setupExpandedView()
        }
    }
    
}

//MARK: - Table View
extension ChatMembersView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier,
                                                 for: indexPath) as! ContactsTableViewCell
        let model = self.users[indexPath.row]
        
        cell.configureCell(title: model.user.getDisplayName(),
                           description: model.user.telephoneNumber,
                           leftImage: model.user.avatarFileId?.fullFilePathFromId(),
                           type: self.editable.value ? .remove : .normal)
        
        cell.onRightClickAction
            .compactMap ({ [weak self] cell in
                return self?.tableView.indexPath(for: cell)
            })
            .subscribe(self.onRemoveUser)
            .store(in: &cell.subscriptions)
        return cell
    }
}
