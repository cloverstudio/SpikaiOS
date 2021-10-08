//
//  DetailsViewModel.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import Foundation

class DetailsViewModel: BaseViewModel {
    
    let id: Int
    
    init(repository: Repository, coordinator: Coordinator, id: Int) {
        self.id = id
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func closeDetialsScreen() {
        getAppCoordinator()?.popTopViewController()
    }
    
}
