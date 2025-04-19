//
//  MoodHistoryCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 19/4/25.
//

import UIKit

struct MoodHistoryWantToDismissEvent: CoordinatorEvent {
    
}

final class MoodHistoryCoordinator: NavigationBaseCoordinator {
    lazy var controller: MoodHistoryViewController = {
        let viewModel = MoodHistoryViewModel()
        let controller = MoodHistoryViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        navigationController.pushViewController(controller, animated: true)
    }

    override func stop(completion: (() -> Void)? = nil) {
        navigationController.popViewController(animated: true)
        super.stop(completion: completion)
    }
    
    func dismiss() {
        self.send(event: MoodHistoryWantToDismissEvent())
    }
}
