//
//  MoodieCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 16/4/25.
//

import UIKit

final class MoodieCoordinator: NavigationBaseCoordinator {
    lazy var controller: MoodieViewController = {
        let viewModel = MoodieViewModel()
        let controller = MoodieViewController(viewModel: viewModel, coordinator: self)
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
}
