//
//  CurrentViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation
import UIKit
import CoreData
import PhotosUI
import Combine
import UniformTypeIdentifiers

struct SelectedFile {
    let fileType: UTType
    let name: String?
    let fileUrl: URL
    let thumbnail: UIImage
}

class CurrentChatViewController: BaseViewController {
    
    private let currentChatView = CurrentChatView()
    var viewModel: CurrentChatViewModel!
    private let friendInfoView = ChatNavigationBarView()
    private var frc: NSFetchedResultsController<MessageEntity>?
    private let audioPlayer = AudioPlayer()
    private var audioSubscribe: AnyCancellable?
    
    private let frcIsChangingPublisher = PassthroughSubject<FRCChangeType, Never>()
    private let frcDidChangePublisher = PassthroughSubject<Bool, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(currentChatView)
        setupNavigationItems()
        setupBindings()
        checkRoom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let room = viewModel.room else { return }
        viewModel.roomVisited(roomId: room.id)
    }
    
    deinit {
//        print("currentChatVC deinit")
    }
}

// MARK: Functions

extension CurrentChatViewController {
    func checkRoom() {
        viewModel.checkLocalRoom()
    }
    
    func setupBindings() {
        currentChatView.messagesTableView.delegate = self
        currentChatView.messagesTableView.dataSource = self
        sink(networkRequestState: viewModel.networkRequestState)
        
        currentChatView.messageInputView.inputViewTapPublisher.sink { [weak self] state in
            self?.handleInput(state)
        }.store(in: &subscriptions)
        
        viewModel.roomPublisher.receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
            // TODO: pop vc?, presentAlert?
            guard let self = self else { return }
            switch completion {
                
            case .finished:
                break
            case let .failure(error):
                break
//                PopUpManager.shared.presentAlert(with: (title: "Error", message: error.localizedDescription), orientation: .horizontal, closures: [("Ok", {
//                    self.viewModel.getAppCoordinator()?.popTopViewController()
//                })]) // TODO: - check
            }
        } receiveValue: { [weak self] room in
            guard let self = self else { return }
            self.setFetch(room: room)
            self.setupNavigationItems()
            self.viewModel.sendSeenStatus()
        }.store(in: &self.subscriptions)
        
        currentChatView.downArrowImageView.tap().sink { [weak self] _ in
            self?.currentChatView.messagesTableView.scrollToBottom(.force)
        }.store(in: &self.subscriptions)
        
        viewModel.selectedFiles.receive(on: DispatchQueue.main).sink { [weak self] files in
            guard let self = self else { return }
            if files.isEmpty {
                self.currentChatView.messageInputView.hideSelectedFiles()
            } else {
                print("FILES COUNT: ", files.count)
                self.currentChatView.messageInputView.showSelectedFiles(files)
                
                let arrangedSubviews = self.currentChatView.messageInputView.selectedFilesView.itemsStackView.arrangedSubviews
                
                arrangedSubviews.forEach { view in
                    if let iw = view as? SelectedFileImageView {
                        iw.deleteImageView.tap().sink { [weak self] _ in
                            guard let self = self,
                                  let index =  arrangedSubviews.firstIndex(of: view)
                            else { return }
                            self.viewModel.selectedFiles.value.remove(at: index)
                        }.store(in: &self.subscriptions)
                    }
                }
            }
        }.store(in: &subscriptions)
        
        viewModel.uploadProgressPublisher.sink { [weak self] (index, progress) in
            guard let self = self else { return }
            if let arrangedSubviews = self.currentChatView.messageInputView.selectedFilesView.itemsStackView.arrangedSubviews as? [SelectedFileImageView] {
                arrangedSubviews[index].showUploadProgress(progress: progress)
            }
            
        }.store(in: &subscriptions)
        
        Publishers
            .Zip(frcIsChangingPublisher, frcDidChangePublisher)
            .filter{$1}
            .sink { [weak self] (frcChange, frcDidChange) in
                guard let self = self else { return }
                
                switch frcChange {
                case .insert(indexPath: let indexPath):
                    guard let messageEntity = self.frc?.object(at: indexPath) else { return }
                    self.handleScroll(isMyMessage: messageEntity.fromUserId == self.viewModel.getMyUserId())
                case .other:
                    break
                }
            }.store(in: &subscriptions)
        
        self.viewModel.repository
            .unreadRoomsPublisher
            .sink { [weak self] value in
                let stringValue = value > 0 ? String(value) : ""
                self?.title = stringValue
            }.store(in: &self.subscriptions)
    }
    
    func handleScroll(isMyMessage: Bool) {
        currentChatView.messagesTableView.scrollToBottom(isMyMessage ? .force : .ifLastCellVisible)
    }
}

// MARK: - NSFetchedResultsController

extension CurrentChatViewController: NSFetchedResultsControllerDelegate {
    
    func setFetch(room: Room) {
        let fetchRequest = MessageEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdDate", ascending: true),
            NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "room.id == %d", room.id)
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.viewModel.repository.getMainContext(), sectionNameKeyPath: "sectionName", cacheName: nil)
        self.frc?.delegate = self
        do {
            try self.frc?.performFetch()
            self.currentChatView.messagesTableView.reloadData()
            self.currentChatView.messagesTableView.layoutIfNeeded()
            self.currentChatView.messagesTableView.scrollToBottom(.force)
        } catch {
            fatalError("Failed to fetch entities: \(error)") // TODO: handle error
        }
        
        viewModel.roomVisited(roomId: room.id)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentChatView.messagesTableView.beginUpdates()
    }
    
    // MARK: - sections
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("DIDCHANGE: sections insert")
            currentChatView.messagesTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("DIDCHANGE: sections delete")
            currentChatView.messagesTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            print("DIDCHANGE: sections move")
            break
        case .update:
            print("DIDCHANGE: sections update")
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - rows
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("TYPE: ", type.rawValue)
        switch type {
        case .insert:
            print("DIDCHANGE: rows insert")
            guard let newIndexPath = newIndexPath else {
                return
            }
            viewModel.sendSeenStatus()
            currentChatView.messagesTableView.insertRows(at: [newIndexPath], with: .fade)
            currentChatView.messagesTableView.reloadPreviousRow(for: newIndexPath)
            frcIsChangingPublisher.send(.insert(indexPath: newIndexPath))
            
        case .delete:
            print("DIDCHANGE: rows delete")
            guard let indexPath = indexPath else {
                return
            }
            currentChatView.messagesTableView.deleteRows(at: [indexPath], with: .none)
            frcIsChangingPublisher.send(.other)
        
        case .move:
            print("DIDCHANGE: rows move")
            guard let indexPath = indexPath,
                  let newIndexPath = newIndexPath
            else {
                return
            }
            currentChatView.messagesTableView.moveRow(at: indexPath, to: newIndexPath)
            frcIsChangingPublisher.send(.other)
        
        case .update:
            print("DIDCHANGE: rows update")
            guard let indexPath = indexPath else {
                return
            }
            UIView.performWithoutAnimation {
                currentChatView.messagesTableView.reloadRows(at: [indexPath], with: .none)
            }
            frcIsChangingPublisher.send(.other)
        
        default:
            frcIsChangingPublisher.send(.other)
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentChatView.messagesTableView.endUpdates()
        frcDidChangePublisher.send(true)
    }
}


// MARK: - MessageInputView actions

extension CurrentChatViewController {
    
    func handleInput(_ state: MessageInputViewState) {
        switch state {
        case .send(let message):
            var referenceMessage: ReferenceMessage?
            
            if let reference = currentChatView.messageInputView.replyView?.message {
                referenceMessage = ReferenceMessage(id: reference.id,
                                                    body: ReferenceBody(text: reference.body?.text),
                                                    fromUserId: reference.fromUserId,
                                                    roomId: reference.roomId,
                                                    type: reference.type)
            }
            
            viewModel.trySendMessage(text: message, referenceMessage: referenceMessage)
            currentChatView.messageInputView.clean()
        case .camera, .microphone:
            print(state, " in ccVC")
        case .emoji:
            print("emoji in ccvc")
        case .files:
            presentFilePicker()
        case .library:
            presentLibraryPicker()
        case .scrollToReply(let indexPath):
            currentChatView.messagesTableView.blinkRow(at: indexPath)
        }
    }
}

// MARK: - MessageCell actions

extension CurrentChatViewController {
    func handleCellTap(_ state: MessageCellTaps, message: Message) {
        switch state {
        case .playVideo:
            viewModel.playVideo(message: message)
        case let .playAudio(playedPercentPublisher):
            guard let url = message.body?.file?.path?.getFullUrl(),
                  let mimeType = message.body?.file?.mimeType
            else { return }
            audioSubscribe?.cancel()
            audioSubscribe = audioPlayer
                .playAudio(url: url, mimeType: mimeType)?
                .sink { [weak self] percent in
                playedPercentPublisher.send(percent)
            }
            audioSubscribe?.store(in: &subscriptions)
        case .openImage:
            guard let url = message.body?.file?.path?.getFullUrl() else { return }
            viewModel.showImage(link: url)
        case .scrollToReply(let indexPath):
            currentChatView.messagesTableView.blinkRow(at: indexPath)
        }
    }
}

// MARK: - UITableView

extension CurrentChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BaseMessageTableViewCell else { return }
        (tableView.visibleCells as? [BaseMessageTableViewCell])?.forEach{ $0.setTimeLabelVisible(false)}
        cell.tapHandler()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let lastIndexPath = tableView.lastCellIndexPath,
              let shouldHide = tableView.indexPathsForVisibleRows?.contains(lastIndexPath)
        else { return }
        currentChatView.hideScrollToBottomButton(should: shouldHide)
    }
}

extension CurrentChatViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.frc?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.frc?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let entity = frc?.object(at: indexPath),
              let roomType = viewModel.room?.type
        else { return EmptyTableViewCell()}
        
        let message = Message(messageEntity: entity)
        let myUserId = viewModel.repository.getMyUserId()
        guard let identifier = message.getReuseIdentifier(myUserId: myUserId, roomType: roomType),
              let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? BaseMessageTableViewCell
        else { return EmptyTableViewCell() }
        
        if let replyId = message.body?.referenceMessage?.id,
           replyId >= 0,
           let repliedMessageEntity = frc?.fetchedObjects?.first(where: { $0.id == "\(replyId)" })
        {
            let repliedMessage = Message(messageEntity: repliedMessageEntity)
            let senderName = viewModel.room?.getDisplayNameFor(userId: repliedMessage.fromUserId)
            
            cell.showReplyView(senderName: senderName ?? .getStringFor(.unknown), message: repliedMessage,
                               sender: cell.getMessageSenderType(reuseIdentifier: identifier),
                               indexPath: frc?.indexPath(forObject: repliedMessageEntity))
        }
        
        switch message.type {
        case .text:
            (cell as? TextMessageTableViewCell)?.updateCell(message: message)
        case .image:
            (cell as? ImageMessageTableViewCell)?.updateCell(message: message)
        case .file:
            (cell as? FileMessageTableViewCell)?.updateCell(message: message)
        case .audio:
            (cell as? AudioMessageTableViewCell)?.updateCell(message: message)
        case .video:
            (cell as? VideoMessageTableViewCell)?.updateCell(message: message)
        case .unknown:
            break
        }
        
        cell.tapPublisher.sink(receiveValue: { [weak self] state in
            self?.handleCellTap(state, message: message)
        }).store(in: &cell.subs)
        
        cell.updateCellState(to: message.getMessageState(myUserId: myUserId))
        cell.updateTime(to: message.createdAt)
        if let user = viewModel.getUser(for: message.fromUserId) {
            if !isPreviousCellMine(for: indexPath) {
                cell.updateSender(name: user.getDisplayName())
            }
            if !isNextCellMine(for: indexPath) {
                cell.updateSender(photoUrl: user.avatarUrl?.getFullUrl())
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sections = self.frc?.sections else { return nil }
        var name = sections[section].name
        if let time = (sections[section].objects?.first as? MessageEntity)?.createdAt {
            name.append(", ")
            name.append(time.convert(to: .HHmm))
        }
        let dateLabel = CustomLabel(text: name, textSize: 11, textColor: .textPrimary, fontName: .MontserratMedium, alignment: .center)
        return dateLabel
    }
    
    func isPreviousCellMine(for indexPath: IndexPath) -> Bool {
        let previousRow = indexPath.row - 1
        if previousRow >= 0 {
            let currentMessageEntity  = frc?.object(at: indexPath)
            let previousMessageEntity = frc?.object(at: IndexPath(row: previousRow,
                                                                  section: indexPath.section))
            return currentMessageEntity?.fromUserId == previousMessageEntity?.fromUserId
        }
        return false
    }
    
    func isNextCellMine(for indexPath: IndexPath) -> Bool {
        guard let sections = frc?.sections else { return true }
        let maxRowsIndex = sections[indexPath.section].numberOfObjects - 1
        let nextRow = indexPath.row + 1
        if nextRow <= maxRowsIndex {
            let currentMessageEntity  = frc?.object(at: indexPath)
            let nextMessageEntity = frc?.object(at: IndexPath(row: nextRow,
                                                              section: indexPath.section))
            return currentMessageEntity?.fromUserId == nextMessageEntity?.fromUserId
        }
        return false
    }
}

// MARK: - Navigation items setup

extension CurrentChatViewController {
    func setupNavigationItems() {
        let videoCallButton = UIBarButtonItem(image: UIImage(safeImage: .videoCall), style: .plain, target: self, action: #selector(videoCallActionHandler))
        let audioCallButton = UIBarButtonItem(image: UIImage(safeImage: .phoneCall), style: .plain, target: self, action: #selector(phoneCallActionHandler))
        
        navigationItem.rightBarButtonItems = [audioCallButton, videoCallButton]
        navigationItem.leftItemsSupplementBackButton = true
        
        if viewModel.room?.type == .privateRoom {
            friendInfoView.change(avatarUrl: viewModel.friendUser?.avatarUrl?.getFullUrl(), name: viewModel.friendUser?.getDisplayName(), lastSeen: .getStringFor(.yesterday))
        } else {
            friendInfoView.change(avatarUrl: viewModel.room?.avatarUrl?.getFullUrl(),
                                  name: viewModel.room?.name,
                                  lastSeen: .getStringFor(.today))
        }
        
        self.navigationItem.titleView = UIView(frame: .zero)
        let vtest = UIBarButtonItem(customView: friendInfoView)
        friendInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onChatDetails)))
        navigationItem.leftBarButtonItem = vtest
    }
    
    @objc func onChatDetails() {
        guard let room = self.viewModel.room else { return }
        let publisher = CurrentValueSubject<Room,Never>(room)
        
        publisher.sink { [weak self] newRoom in
            self?.viewModel.room = newRoom
        }.store(in: &self.subscriptions)
        
        self.viewModel.getAppCoordinator()?.presentChatDetailsScreen(room: publisher)
    }
    
    @objc func videoCallActionHandler() {
    }
    
    @objc func phoneCallActionHandler() {
        
    }
}

// MARK: - swipe gestures on cells

extension CurrentChatViewController {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let firstRight = UIContextualAction(style: .normal, title: .getStringFor(.details)) { [weak self] (action, view, completionHandler) in
            if let messageEntity = self?.frc?.object(at: indexPath),
               let records = Message(messageEntity: messageEntity).records {
                self?.viewModel.presentMessageDetails(records: records)
                completionHandler(true)
            }
        }
        firstRight.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [firstRight])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let firstLeft = UIContextualAction(style: .normal, title: .getStringFor(.reply)) { [weak self] (action, view, completionHandler) in
            
            guard let messageEntity = self?.frc?.object(at: indexPath) else { return }
            let message = Message(messageEntity: messageEntity)
            let senderName = self?.viewModel.room?.getDisplayNameFor(userId: message.fromUserId)
            
            self?.currentChatView.messageInputView.showReplyView(senderName: senderName ?? .getStringFor(.unknown), message: message, indexPath: indexPath)
            
            completionHandler(true)
        }
        firstLeft.backgroundColor = .logoBlue
        return UISwipeActionsConfiguration(actions: [firstLeft])
    }
    
}

// MARK: - Photo Video picker

extension CurrentChatViewController: PHPickerViewControllerDelegate {
    
    func presentLibraryPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        
        configuration.filter = .any(of: [.images, .livePhotos, .videos]) // TODO: check
        configuration.preferredAssetRepresentationMode = .current
        configuration.selectionLimit = 30
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        print("RESULTS COUNT: ", results.count)
        for result in results {
            
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, error in
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                    guard let url = url,
                          let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent),
                          url.copyFileFromURL(to: targetURL) == true
                    else { return }
                    let thumbnail = targetURL.imageThumbnail()
                    let file = SelectedFile(fileType: .image, name: nil,
                                            fileUrl: targetURL, thumbnail: thumbnail)
                    self?.viewModel.selectedFiles.value.append(file)
                }
            }
            
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                    guard let url = url,
                          let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent),
                          url.copyFileFromURL(to: targetURL) == true
                    else { return }
                    let thumb = url.videoThumbnail()
                    let file  = SelectedFile(fileType: .movie, name: "video",
                                             fileUrl: targetURL, thumbnail: thumb)
                    self?.viewModel.selectedFiles.value.append(file)
                }
            }
        }
    }
}

// MARK: - File picker

extension CurrentChatViewController: UIDocumentPickerDelegate {
    func presentFilePicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        for url in urls {
            guard let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent),
                  url.copyFileFromURL(to: targetURL) == true,
                  let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey, .nameKey]),
                  let fileName = resourceValues.name,
                  let type = resourceValues.contentType
            else { return }
            
            let file = SelectedFile(fileType: type, name: fileName,
                                    fileUrl: targetURL, thumbnail: type.thumbnail())
            self.viewModel.selectedFiles.value.append(file)
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
