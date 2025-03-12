//
//  SplashCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import UIKit

final class SplashCoordinator: Coordinator {
    lazy var controller: SplashViewController = {
        let viewModel = SplashViewModel()
        let controller = SplashViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
    }

    override func stop(completion: (() -> Void)? = nil) {
        super.stop(completion: completion)
    }
}
