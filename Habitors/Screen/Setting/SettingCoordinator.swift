//
//  SettingCoordinator.swift
//  Habitors
//
//  Created by Thanh Vu on 22/4/25.
//

import UIKit

final class SettingCoordinator: NavigationBaseCoordinator {
    lazy var controller: SettingViewController = {
        let viewModel = SettingViewModel()
        let controller = SettingViewController(viewModel: viewModel, coordinator: self)
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
