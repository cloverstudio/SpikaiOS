//
//  EnterUsernameViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.01.2022..
//

import UIKit

class EnterUsernameViewController: BaseViewController {
    
    private let enterUsernameView = EnterUsernameView()
    var viewModel: EnterUsernameViewModel!
    var fileData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(enterUsernameView)
        setupBindings()
    }
    
    func setupBindings() {
        sink(networkRequestState: viewModel.networkRequestState)
        
        enterUsernameView.profilePictureView.tap().sink { [weak self] _ in
            self?.showChangeImageActionSheet()
        }.store(in: &subscriptions)
        
        enterUsernameView.nextButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            if let username = self.enterUsernameView.usernameTextfield.text {
                self.viewModel.updateUser(username: username, imageFileData: self.fileData)
            }
        }.store(in: &subscriptions)
        
        viewModel.uploadProgressPublisher.sink { [weak self] completion in
            guard let self = self else { return }
            
            switch completion {
            case .finished:
                break
            case .failure(_):
                self.fileData = nil
                self.enterUsernameView.profilePictureView.deleteMainImage()
                self.enterUsernameView.profilePictureView.hideUploadProgress()
            }
        } receiveValue: { [weak self] progress in
            guard let self = self else { return }
            self.enterUsernameView.profilePictureView.showUploadProgress(progress: progress)
        }.store(in: &subscriptions)
        
        imagePickerPublisher.sink { [weak self] pickedImage in
            let photoStatus = pickedImage.statusOfPhoto(for: .avatar)
            switch photoStatus {
            case .allOk:
                break
            default:
                guard let resizedImage = pickedImage.resizeImageToFitPixels(size: CGSize(width: 512, height: 512)) else { return }
                self?.enterUsernameView.profilePictureView.showImage(resizedImage)
                self?.fileData = resizedImage.jpegData(compressionQuality: 1)
            }
        }.store(in: &subscriptions)
    }
    
    func showChangeImageActionSheet() {
        viewModel
            .getAppCoordinator()?
            .showAlert(actions: [.regular(title: .getStringFor(.takeAPhoto)),
                                 .regular(title: .getStringFor(.chooseFromGallery)),
                                 .destructive(title: .getStringFor(.removePhoto))])
            .sink(receiveValue: { [weak self] tappedIndex in
                switch tappedIndex {
                case 0:
                    self?.showUIImagePicker(source: .camera)
                case 1:
                    self?.showUIImagePicker(source: .photoLibrary)
                case 2:
                    self?.fileData = nil
                    self?.enterUsernameView.profilePictureView.deleteMainImage()
                default:
                    break
                }
            }).store(in: &subscriptions)
    }
}
