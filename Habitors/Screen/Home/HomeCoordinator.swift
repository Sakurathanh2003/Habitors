//
//  HomeCoordinator.swift
//  Habitors
//
//  Created by CucPhung on 13/3/25.
//

import UIKit

final class HomeCoordinator: Coordinator {
    lazy var controller: HomeViewController = {
        let viewModel = HomeViewModel()
        let controller = HomeViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
    }

    override func stop(completion: (() -> Void)? = nil) {
        super.stop(completion: completion)
    }
}
