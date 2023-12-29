//
//  SelectUsersOrGroupsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.11.2023..
//
import Kingfisher
import SwiftUI
import CoreData


enum SelectUsersOrGroupsPurpose {
    case forwardMessages([Int64])
    case addToExistingGroup(hiddenUserIds: [Int64])
    case addToNewGroupCreationFlow(hiddenUserIds: [Int64])
    
    var title: String {
        switch self {
        case .forwardMessages(let array):
            array.count <= 1 ? "Forward message" : "Forward messages"
        case .addToExistingGroup:
            "Add to group"
        case .addToNewGroupCreationFlow:
            "Add to new group flow"
        }
    }
    
    var hideUserIds: [Int64] {
        // hide already added users (e.g. when adding to existing grups)
        switch self {
        case .addToExistingGroup(let hiddenUserIds): hiddenUserIds
        case .addToNewGroupCreationFlow(let hiddenUserIds): hiddenUserIds
        case .forwardMessages: []
        }
    }
    
    var showUsersAndGroupsToggle: Bool {
        switch self {
        case .forwardMessages: true
        default: false
        }
    }
}

struct SelectUsersOrGroupsView: View {
    @StateObject var viewModel: SelectUsersOrGroupsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            titleAndClose()
                .padding(.vertical, 10)
            
            TextField("", text: $viewModel.searchTerm, prompt: Text(verbatim: .getStringFor(.search)))
                .frame(height: 38)
                .padding(.horizontal, 12)
                .background(Color(.thirdAdditionalColor))
                .clipShape(Capsule())
            
            if viewModel.purpose.showUsersAndGroupsToggle {
                contactsOrGroupToggle()
                    .padding(.vertical, 8)
            }
            
            selectedMembersView()
            
            if viewModel.isUsersSelected {
                ListWithPredicate(sI: \.sectionName, sD: viewModel.usersSortDescriptor, p: viewModel.usersPredicate) { (userEntity: UserEntity) in
                    memberRow(.user(userEntity))
                        .listRowBackground(Color(.secondaryColor))
                }
            } else {
                ListWithPredicate(sI: \.sectionName, sD: viewModel.roomsSortDescriptor, p: viewModel.roomsPredicate) { (roomEntity: RoomEntity) in
                    memberRow(.room(roomEntity))
                        .listRowBackground(Color(.secondaryColor))
                }
            }
            
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .background(Color(.secondaryColor))
    }
    
    private func titleAndClose() -> some View {
        HStack {
            Text(viewModel.purpose.title) // TODO: - change
            Spacer()
            Button {
                viewModel.endButtonTap()
            } label: {
                Image(.rDx)
            }
        }
    }
    
    private func contactsOrGroupToggle() -> some View {
        HStack(spacing: 5) {
            Button {
                viewModel.isUsersSelected = true
            } label: {
                Text(verbatim: .getStringFor(.users))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundStyle(Color.fromUIColor(.textPrimary))
                    .background(viewModel.isUsersSelected
                                ? Color.fromUIColor(.primaryColor)
                                : .fromUIColor(.fourthAdditionalColor))
                    .modifier(RoundedCorners(corners: .leftCorners, radius: 15))
            }
            
            Button {
                viewModel.isUsersSelected = false
            } label: {
                Text(verbatim: .getStringFor(.groups))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundStyle(Color.fromUIColor(.textPrimary))
                    .background(viewModel.isUsersSelected
                                ? .fromUIColor(.fourthAdditionalColor)
                                : Color.fromUIColor(.primaryColor))
                    .modifier(RoundedCorners(corners: .rightCorners, radius: 15))
            }
        }
    }
    
    private func selectedMembersView() -> some View {
        VStack(spacing: 0) {
            Text("\(viewModel.selectedUsersAndGroups.count) selected")
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(viewModel.selectedUsersAndGroups) { selectedThing in
                        VStack(spacing: 0)  {
                            KFImage(selectedThing.avatarURL)
                                .placeholder { _ in
                                    Image(selectedThing.placeholderImage)
                                        .resizable()
                                }
                                .resizable()
                                .clipShape(Circle())
                                .padding()
                                .frame(width: 84, height: 84)
                                .overlay(alignment: .topTrailing) {
                                    Button(action: {
                                        viewModel.selectedUsersAndGroups.removeFirstIfExist(selectedThing)
                                    }, label: {
                                        Image(.rDx)
                                            .tint(Color(.textPrimary))
                                            .background(Color(.primaryColor).clipShape(Circle()))
                                            .padding(.trailing, 8)
                                            .padding(.top, 8)
                                    })
                                }
                            Text(selectedThing.displayName)
                                .frame(maxWidth: 84)
                        }
                    }
                }
                .fixedSize()
            }
        }
        .padding(.vertical, 8)
    }
    
    private func memberRow(_ thing: SelectedUserOrGroup) -> some View {
        Button {
            viewModel.selectedUsersAndGroups.toggle(thing)
        } label: {
            HStack(spacing: 16) {
                KFImage(thing.avatarURL)
                    .placeholder { _ in
                        Image(thing.placeholderImage)
                            .resizable()
                    }
                    .resizable()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                
                VStack {
                    Text(thing.displayName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(thing.description ?? "-")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.foregroundStyle(Color(.textPrimary))
                
                Spacer()
                if viewModel.selectedUsersAndGroups.contains(thing) {
                    Image(.rDcheckmark)
                        .tint(Color(.textPrimary))
                }
            }
        }
    }
}
