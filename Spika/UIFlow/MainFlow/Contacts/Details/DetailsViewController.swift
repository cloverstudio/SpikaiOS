//
//  DetailsViewController.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import UIKit
import AVFoundation


class DetailsViewController: BaseViewController {
    
    private let detailsView = DetailsView()
    var viewModel: DetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(detailsView)
        setupBindings()
        navigationItem.title = "detailll"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    private func setupBindings() {
        detailsView.contentView.sharedMediaOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentSharedScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.chatSearchOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentChatSearchScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.favoriteMessagesOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentFavoritesScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.notesOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentNotesScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.callHistoryOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentCallHistoryScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.videoCallButton.tap().sink { [weak self] _ in
            guard let url = URL(string: "https://conference2.spika.chat/conference/spika3web") else { return }
//            guard let url = URL(string: "https://webrtc.github.io/samples/src/content/getusermedia/gum/") else { return }

            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized,
               AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
                print("jes")
            } else {
                print("no")
            }
            
            self?.viewModel.presentVideoCallScreen(url: url)
        }.store(in: &subscriptions)
    }
    
    
    deinit {
        print("DetailsViewController deinit")
    }
    
}
