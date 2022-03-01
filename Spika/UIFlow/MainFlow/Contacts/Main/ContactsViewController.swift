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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
        
    func setupBindings() {
        contactsView.tableView.dataSource = self
        contactsView.tableView.delegate   = self
        
        viewModel.testtest("mia s")
        
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
        
        viewModel.models.receive(on: DispatchQueue.main).sink { names in
            self.contactsView.tableView.reloadData()

        }.store(in: &subscriptions)
        
        viewModel.getContacts()
        viewModel.getOnlineContacts(page: 1)
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
//        return "KITA"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.lettersPublisher.value.count
//        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.models.value.filter{$0.displayName!.starts(with: viewModel.models.value[section].displayName!)}.count
//        return viewModel.models.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier, for: indexPath) as? ContactsTableViewCell
//        cell?.configureCell(image: UIImage(named: "matejVida")!, name:
//                                viewModel.namesPublisher.value.filter{ $0.starts(with: viewModel.lettersPublisher.value[indexPath.section])}[indexPath.row], desc: "test")
////                                viewModel.namesPublisher.value[indexPath.row], desc: "test34")
//        
//        cell?.configureCell(viewModel.models.value[indexPath.item])
        
        cell?.configureCell(viewModel.models.value.filter{
            $0.displayName!.starts(with: viewModel.models.value[indexPath.section].displayName!)}[indexPath.row])
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("t: ", indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.showDetailsScreen(id: 3)
    }
}

