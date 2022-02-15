//
//  ContactsViewController.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit
import Combine

class ContactsViewController: BaseViewController {
    
    private let contactsView = ContactsView()
    var viewModel: ContactsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(contactsView)
        setupBindings()
        
        self.viewModel.getChats()
    }
    
    var testC = 0
    
    func setupBindings() {
        contactsView.tableView.dataSource = self
        contactsView.tableView.delegate   = self
        
        viewModel.testtest("mia s")
        contactsView.titleLabel.tap().sink { tap in
            print("tap")
            
            switch self.testC {
            case 0:
                self.viewModel.testtest("jozo")
            case 1:
                self.viewModel.testtest("ana")
            case 2:
                self.viewModel.testtest("marko")
            case 3:
                self.viewModel.testtest("aine")
            case 4:
                self.viewModel.testtest("papa")
            case 5:
                self.viewModel.testtest("roki")
            case 6:
                self.viewModel.testtest("roberrt")
            default:
                self.viewModel.testtest("tin")
            }
            self.testC += 1
        }.store(in: &subscriptions)
        
        contactsView.detailsButton.tap().sink { _ in
            self.viewModel.showDetailsScreen(id: 3)
    //        viewModel.createChat(name: "first chat", type: "group", id: 1)
    //        let user1 = User(loginName: "Marko", avatarUrl: nil, localName: "Marko", id: 1, blocked: false)
    //        viewModel.repository.saveUser(user1)
    //        let chat = Chat(name: "first chat", id: 1, type: "group")
    //        let message = Message(chat: chat, user: user1, message: "SecondMEssage", id: 1)
    //        viewModel.saveMessage(message: message)
    //        viewModel.getUsersForChat(chat: chat)
    //        viewModel.getMessagesForChat(chat: chat)
        }.store(in: &subscriptions)
        
        viewModel.chatsSubject
            .receive(on: DispatchQueue.main)
            .sink { chats in
                print(chats)
            }.store(in: &subscriptions)
        
//        viewModel.lettersPublisher.receive(on: DispatchQueue.main).sink { letters in
//            contactsView.tableView.reloadData()
//        }.store(in: &subscriptions)
        
        viewModel.namesPublisher.receive(on: DispatchQueue.main).sink { names in
            self.contactsView.tableView.reloadData()

        }.store(in: &subscriptions)
        
    }
    
}

extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
}

extension ContactsViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.lettersPublisher.value[section].uppercased()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.lettersPublisher.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.namesPublisher.value.filter{$0.starts(with: viewModel.lettersPublisher.value[section])}.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier, for: indexPath) as? ContactsTableViewCell
        cell?.configureCell(image: UIImage(named: "matejVida")!, name:
                                viewModel.namesPublisher.value.filter{ $0.starts(with: viewModel.lettersPublisher.value[indexPath.section])}[indexPath.row], desc: "test")
//                                viewModel.namesPublisher.value[indexPath.row], desc: "test34")
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("t: ", indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.showDetailsScreen(id: 3)
    }
}

